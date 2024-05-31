{ ... }: {
  launchd.user.agents.ssh-agent = {
    command = "/opt/homebrew/bin/ssh-agent -D -a ~/.ssh/agent";
    serviceConfig = {
      Label = "ssh-agent";
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/ssh-agent.out.log";
      StandardErrorPath = "/tmp/ssh-agent.err.log";
    };
  };
}
