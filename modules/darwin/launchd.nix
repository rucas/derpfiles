{ ... }:
{
  launchd.agents.maccy = {
    serviceConfig = {
      Label = "com.rucas.maccy";
      ProgramArguments = [ "/Applications/Maccy.app/Contents/MacOS/Maccy" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      ProcessType = "Interactive";
    };
  };
}
