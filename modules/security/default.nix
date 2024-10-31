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

}
