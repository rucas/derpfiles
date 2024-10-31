{ ... }:
{
  #services.gpg-agent = {
  #  enable = true;
  #  enableSshSupport = true;
  #  enableExtraSocket = true;
  #};

  #security.pam.services = {
  #  sudo = {
  #    u2fAuth = true;
  #    sshAgentAuth = true;
  #  };
  #};

  #services.gpg-agent = {
  #  enable = true;
  #  enableSshSupport = true;
  #  enableExtraSocket = true;
  #  pinentryPackage = (lib.mkIf pkgs.stdenv.isDarwin pkgs.pinentry_mac);
  #};

  #programs.gpg = {
  #  enable = true;
  #  settings = { armor = true; };
  #};
}
