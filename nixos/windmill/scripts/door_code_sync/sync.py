"""Sync lldap door codes to Lock Code Manager (the lock) and Alarmo.

lldap is the source of truth: every member of the access group with a
`door-code` attribute becomes a Lock Code Manager user (which pushes the PIN to
the lock) and an Alarmo user with the same name and code. Users this script
created and that later leave the group, or lose their code, are removed from
both. Users it did not create are never touched; the names it manages are kept
in a small state file (names only, never codes).

Nothing here prints or returns a code. The last stdout line is a JSON summary,
which Windmill keeps as the job result.
"""

import argparse
import base64
import json
import os
import re
import sys
import urllib.request

import bcrypt
from websockets.sync.client import connect

CODE_ATTRIBUTE = "door-code"
LCM_DOMAIN = "lock_code_manager"
CODE_RE = re.compile(r"^\d{4,10}$")


def read_secret(path):
    with open(path, encoding="utf-8") as f:
        return f.read().strip()


def http_json(url, body=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


# --- lldap -----------------------------------------------------------------


def lldap_desired(url, user, password, group):
    """Return {name: code} for the users that should have a door code."""
    token = http_json(
        f"{url}/auth/simple/login", {"username": user, "password": password}
    )["token"]
    query = """
      { users { id displayName attributes { name value } groups { displayName } } }
    """
    result = http_json(f"{url}/api/graphql", {"query": query}, token)
    if result.get("errors"):
        raise RuntimeError(f"lldap GraphQL error: {result['errors']}")

    desired, invalid = {}, []
    for u in result["data"]["users"]:
        if group and group not in {g["displayName"] for g in u["groups"]}:
            continue
        attrs = {a["name"].lower(): a["value"] for a in u["attributes"]}
        code = (attrs.get(CODE_ATTRIBUTE) or [""])[0].strip()
        if not code:
            continue
        name = u["displayName"].strip() or u["id"]
        if not CODE_RE.match(code):
            invalid.append(name)
            continue
        desired[name] = code
    return desired, invalid


# --- Home Assistant websocket ----------------------------------------------


class HomeAssistant:
    def __init__(self, url, token):
        self.url = url
        self.token = token
        ws_url = re.sub(r"^http", "ws", url) + "/api/websocket"
        self.ws = connect(ws_url, max_size=None, open_timeout=30)
        self.msg_id = 0
        assert json.loads(self.ws.recv())["type"] == "auth_required"
        self.ws.send(json.dumps({"type": "auth", "access_token": token}))
        reply = json.loads(self.ws.recv())
        if reply["type"] != "auth_ok":
            raise RuntimeError(f"Home Assistant auth failed: {reply.get('message')}")

    def call(self, msg_type, **fields):
        self.msg_id += 1
        self.ws.send(json.dumps({"id": self.msg_id, "type": msg_type, **fields}))
        while True:
            reply = json.loads(self.ws.recv())
            if reply.get("id") == self.msg_id and reply["type"] == "result":
                break
        if not reply["success"]:
            raise RuntimeError(f"{msg_type}: {reply['error']['message']}")
        return reply["result"]

    def service(self, domain, service, data):
        return self.call(
            "call_service", domain=domain, service=service, service_data=data
        )

    def alarmo_post(self, body):
        """Alarmo creates/updates/removes users only through this HTTP view."""
        reply = http_json(f"{self.url}/api/alarmo/users", body, self.token)
        if not reply.get("success"):
            raise RuntimeError(reply.get("error") or "unknown Alarmo error")

    def close(self):
        self.ws.close()


# --- Lock Code Manager -----------------------------------------------------


def lcm_users(ha, entry_title):
    """Return {casefolded name: {"pin", "enabled"}} for one LCM config entry.

    Lock Code Manager treats names case-insensitively, so lookups do too.
    """
    entries = ha.call("config_entries/get", domain=LCM_DOMAIN)
    entry_ids = [e["entry_id"] for e in entries if e["title"] == entry_title]
    if not entry_ids:
        raise RuntimeError(f"no {LCM_DOMAIN} config entry titled {entry_title!r}")
    entry_id = entry_ids[0]

    entity_ids = {
        e["entity_id"]
        for e in ha.call("config/entity_registry/list")
        if e.get("config_entry_id") == entry_id and e.get("platform") == LCM_DOMAIN
    }

    slots = {}
    for state in ha.call("get_states"):
        if state["entity_id"] not in entity_ids:
            continue
        attrs = state["attributes"]
        field, slot = attrs.get("slot_field"), attrs.get("code_slot")
        if slot is None or field not in ("name", "pin", "enabled"):
            continue
        slots.setdefault(slot, {})[field] = state["state"]

    users = {}
    for fields in slots.values():
        name = fields.get("name")
        if not name or name in ("unknown", "unavailable"):
            continue
        users[name.casefold()] = {
            "pin": fields.get("pin", ""),
            "enabled": fields.get("enabled") == "on",
        }
    return users


def sync_lcm(ha, entry_title, desired, managed, dry_run, actions, errors):
    current = lcm_users(ha, entry_title)
    target = {"config_entry_title": entry_title}
    still_managed = set()

    for name, code in sorted(desired.items()):
        cur = current.get(name.casefold())
        try:
            if cur is None:
                actions.append(f"lock: add {name}")
                if not dry_run:
                    ha.service(
                        LCM_DOMAIN,
                        "add_user",
                        {**target, "users": [{"name": name, "pin": code, "enabled": True}]},
                    )
            elif cur["pin"] != code:
                actions.append(f"lock: set code for {name}")
                if not dry_run:
                    ha.service(
                        LCM_DOMAIN,
                        "set_credential",
                        {
                            **target,
                            "name": name,
                            "credential_type": "pin",
                            "value": code,
                            "enable_if_disabled": True,
                        },
                    )
            elif not cur["enabled"]:
                actions.append(f"lock: enable {name}")
                if not dry_run:
                    ha.service(LCM_DOMAIN, "enable_user", {**target, "name": name})
            # Only names this script added (or already managed) are its to
            # delete later; an existing same-named user is adopted.
            still_managed.add(name)
        except RuntimeError as err:
            errors.append(f"lock: {name}: {err}")
            if name in managed:
                still_managed.add(name)

    for name in sorted(managed - desired.keys()):
        if name.casefold() not in current:
            continue
        actions.append(f"lock: delete {name}")
        try:
            if not dry_run:
                ha.service(
                    LCM_DOMAIN,
                    "delete_user",
                    {**target, "name": [name], "clear_credentials": True},
                )
        except RuntimeError as err:
            errors.append(f"lock: {name}: {err}")
            still_managed.add(name)

    return still_managed


# --- Alarmo ----------------------------------------------------------------


def alarmo_code_matches(user, code):
    stored = user.get("code") or ""
    if not stored:
        return False
    try:
        return bcrypt.checkpw(code.encode(), base64.b64decode(stored))
    except ValueError:
        return False


def sync_alarmo(ha, desired, managed, dry_run, actions, errors):
    by_name = {u["name"]: u for u in ha.call("alarmo/users").values()}
    still_managed = set()

    for name, code in sorted(desired.items()):
        user = by_name.get(name)
        try:
            if user is None:
                actions.append(f"alarmo: add {name}")
                if not dry_run:
                    ha.alarmo_post(
                        {
                            "name": name,
                            "code": code,
                            "enabled": True,
                            "can_arm": True,
                            "can_disarm": True,
                            "is_override_code": False,
                            "area_limit": [],
                        }
                    )
            elif not alarmo_code_matches(user, code):
                # Alarmo only changes an existing user's code when given the
                # old one, which is never kept; recreate the user instead,
                # carrying over its permissions.
                actions.append(f"alarmo: replace code for {name}")
                if not dry_run:
                    ha.alarmo_post({"user_id": user["user_id"], "remove": True})
                    ha.alarmo_post(
                        {
                            "name": name,
                            "code": code,
                            "enabled": True,
                            "can_arm": user.get("can_arm", True),
                            "can_disarm": user.get("can_disarm", True),
                            "is_override_code": user.get("is_override_code", False),
                            "area_limit": user.get("area_limit") or [],
                        }
                    )
            elif not user.get("enabled", True):
                actions.append(f"alarmo: enable {name}")
                if not dry_run:
                    ha.alarmo_post({"user_id": user["user_id"], "enabled": True})
            still_managed.add(name)
        except (RuntimeError, OSError) as err:
            errors.append(f"alarmo: {name}: {err}")
            if name in managed:
                still_managed.add(name)

    for name in sorted(managed - desired.keys()):
        user = by_name.get(name)
        if user is None:
            continue
        actions.append(f"alarmo: delete {name}")
        try:
            if not dry_run:
                ha.alarmo_post({"user_id": user["user_id"], "remove": True})
        except (RuntimeError, OSError) as err:
            errors.append(f"alarmo: {name}: {err}")
            still_managed.add(name)

    return still_managed


# --- main ------------------------------------------------------------------


def load_state(path):
    try:
        with open(path, encoding="utf-8") as f:
            state = json.load(f)
    except FileNotFoundError:
        state = {}
    return {k: set(state.get(k, [])) for k in ("lock", "alarmo")}


def save_state(path, state):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = f"{path}.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump({k: sorted(v) for k, v in state.items()}, f, indent=2)
    os.replace(tmp, path)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--lldap-url", required=True)
    p.add_argument("--lldap-user", required=True)
    p.add_argument("--lldap-password-file", required=True)
    p.add_argument("--group", default="door_access", help="empty for every user")
    p.add_argument("--ha-url", required=True)
    p.add_argument("--ha-token-file", required=True)
    p.add_argument("--lcm-entry", required=True, help="Lock Code Manager entry title")
    p.add_argument("--state-file", required=True)
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    desired, invalid = lldap_desired(
        args.lldap_url.rstrip("/"),
        args.lldap_user,
        read_secret(args.lldap_password_file),
        args.group,
    )
    errors = [f"lldap: {n}: {CODE_ATTRIBUTE} must be 4-10 digits" for n in invalid]
    actions = []

    state = load_state(args.state_file)
    ha = HomeAssistant(args.ha_url.rstrip("/"), read_secret(args.ha_token_file))
    try:
        new_state = {
            "lock": sync_lcm(
                ha, args.lcm_entry, desired, state["lock"], args.dry_run, actions, errors
            ),
            "alarmo": sync_alarmo(
                ha, desired, state["alarmo"], args.dry_run, actions, errors
            ),
        }
    finally:
        ha.close()

    if not args.dry_run:
        save_state(args.state_file, new_state)

    for line in actions:
        print(line, file=sys.stderr)
    for line in errors:
        print(f"ERROR {line}", file=sys.stderr)
    print(
        json.dumps(
            {
                "dry_run": args.dry_run,
                "users": sorted(desired),
                "actions": actions,
                "errors": errors,
            }
        )
    )
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
