{ config, pkgs, ... }:
#
# Pull master and rebuild, on the box itself.
#
# Pull-based rather than push-based: no root SSH key in GitHub Actions, and the
# box converges on its own after being offline. The real `git` binary is used
# (not comin's go-git) because only it honours the git-crypt smudge filter —
# without it `secrets/adguard-rules-rucaslab.toml` arrives encrypted and
# `builtins.fromTOML` in nixos/adguard throws.
#
# One-time bootstrap, by hand on the box:
#
#   sudo git clone https://github.com/rucas/derpfiles.git /var/lib/derpfiles
#   sudo git-crypt unlock /path/to/git-crypt-key   # run inside the clone
#
let
  flakePath = "/var/lib/derpfiles";
  gitCryptCanary = "${flakePath}/secrets/adguard-rules-rucaslab.toml";
  ntfyTopic = "http://localhost${config.services.ntfy-sh.settings.listen-http}/rucaslab";

  # ExecCondition, not ExecStartPre: exit 0 runs the unit, 1-254 skips it
  # silently, >=255 fails it. "Already up to date" must skip, or the box
  # re-evaluates the whole system every five minutes for nothing. Everything
  # that is actually broken exits 255 so onFailure fires.
  fetchMaster = pkgs.writeShellApplication {
    name = "autoupgrade-fetch-master";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      die() {
          echo "$*" >&2
          exit 255
      }

      cd ${flakePath} || die "${flakePath} is missing - clone it and run git-crypt unlock"

      git fetch --prune origin master || die "git fetch failed"

      if [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/master)" ]; then
          echo "Already at origin/master, nothing to deploy"
          exit 1
      fi

      git merge --ff-only origin/master ||
          die "fast-forward to origin/master failed - the checkout is dirty or diverged"

      if [ "$(head -c 9 ${gitCryptCanary} | tr -d '\0')" = "GITCRYPT" ]; then
          die "${gitCryptCanary} is still encrypted - run git-crypt unlock in ${flakePath}"
      fi
    '';
  };

  notifyFailure = pkgs.writeShellApplication {
    name = "autoupgrade-notify";
    runtimeInputs = [
      pkgs.curl
      config.systemd.package
    ];
    text = ''
      journalctl --unit nixos-upgrade.service --lines 30 --no-pager |
          curl --silent --show-error --fail \
              --header "Title: rucaslab auto-upgrade failed" \
              --header "Priority: high" \
              --header "Tags: warning" \
              --data-binary @- \
              ${ntfyTopic}
    '';
  };
in
{
  system.autoUpgrade = {
    enable = true;
    flake = flakePath;
    operation = "switch";
    # The lockfile is what CI built and what master promises; --upgrade would
    # bump nixpkgs behind its back.
    upgrade = false;
    dates = "*:0/5";
    randomizedDelaySec = "30";
  };

  systemd.services = {
    nixos-upgrade = {
      serviceConfig.ExecCondition = "${fetchMaster}/bin/autoupgrade-fetch-master";
      onFailure = [ "autoupgrade-notify.service" ];
    };

    autoupgrade-notify = {
      description = "Push a ntfy alert when nixos-upgrade fails";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notifyFailure}/bin/autoupgrade-notify";
      };
    };
  };

  # git-crypt unlock records an absolute store path as the clone's filter;
  # nix.gc would collect it and the filter would silently stop working.
  environment.systemPackages = [ pkgs.git-crypt ];
}
