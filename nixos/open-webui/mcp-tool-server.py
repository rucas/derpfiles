"""Emit Open WebUI's TOOL_SERVER_CONNECTIONS for Outline's MCP server.

Open WebUI only registers an OAuth 2.1 MCP client when the connection carries
an `info.oauth_client_info` blob — a Fernet token under
OAUTH_CLIENT_INFO_ENCRYPTION_KEY that upstream mints in the admin UI and keeps
in the config table. With ENABLE_PERSISTENT_CONFIG=False that table is never
read, so the blob is built here instead and the connection is handed to the
service as an environment file.

Inputs arrive as environment variables; argv[1] is the file to write.
"""

import base64
import hashlib
import json
import os
import sys

from cryptography.fernet import Fernet


def fernet_key(key: str) -> bytes:
    """Open WebUI hashes any key that is not already a Fernet key."""
    if len(key) == 44:
        return key.encode()
    return base64.urlsafe_b64encode(hashlib.sha256(key.encode()).digest())


def main() -> None:
    outline_url = os.environ["OUTLINE_URL"].rstrip("/")
    mcp_url = f"{outline_url}/mcp"
    client_id = os.environ["OUTLINE_OAUTH_CLIENT_ID"]
    client_secret = os.environ["OUTLINE_OAUTH_CLIENT_SECRET"]
    scope = os.environ["MCP_OAUTH_SCOPE"]

    # Inlined instead of discovered so service start stays off the network.
    # Open WebUI rediscovers and re-registers from oauth_client_id/secret if
    # this ever goes stale.
    server_metadata = {
        "issuer": outline_url,
        "authorization_endpoint": f"{outline_url}/oauth/authorize",
        "token_endpoint": f"{outline_url}/oauth/token",
        "revocation_endpoint": f"{outline_url}/oauth/revoke",
        "registration_endpoint": f"{outline_url}/oauth/register",
        "response_types_supported": ["code"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "token_endpoint_auth_methods_supported": ["client_secret_post", "none"],
        "code_challenge_methods_supported": ["S256"],
        "scopes_supported": ["read", "write"],
    }

    client_info = {
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uris": [os.environ["MCP_OAUTH_REDIRECT_URI"]],
        "grant_types": ["authorization_code", "refresh_token"],
        "response_types": ["code"],
        "token_endpoint_auth_method": "client_secret_post",
        "scope": scope,
        # Open WebUI passes `issuer` to authlib as the metadata URL
        "issuer": f"{outline_url}/.well-known/oauth-authorization-server",
        "resource": mcp_url,
        "oauth_resource_parameter": "auto",
        "server_metadata": server_metadata,
    }

    fernet = Fernet(fernet_key(os.environ["OAUTH_CLIENT_INFO_ENCRYPTION_KEY"]))
    connection = {
        "type": "mcp",
        "url": mcp_url,
        "path": "",
        "auth_type": "oauth_2.1_static",
        "key": "",
        "config": {
            "enable": True,
            # Everyone who gets past Authelia, rather than admins only (what a
            # connection without grants means). Each of them still authorizes
            # against Outline individually and sees only their own documents.
            "access_grants": [
                {
                    "principal_type": "user",
                    "principal_id": "*",
                    "permission": "read",
                }
            ],
        },
        "info": {
            "id": os.environ["MCP_SERVER_ID"],
            "name": "Outline",
            "description": "rucaslab wiki",
            "oauth_client_id": client_id,
            "oauth_client_secret": client_secret,
            "oauth_scope": scope,
            "oauth_client_info": fernet.encrypt(
                json.dumps(client_info).encode()
            ).decode(),
        },
    }

    # systemd reads single quotes as quoting; the JSON itself has none.
    with open(sys.argv[1], "w") as out:
        out.write(f"TOOL_SERVER_CONNECTIONS='{json.dumps([connection])}'\n")


if __name__ == "__main__":
    main()
