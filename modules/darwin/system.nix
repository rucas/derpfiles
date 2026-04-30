_: {

  system = {
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        # show only active in dock
        static-only = true;
      };
      NSGlobalDomain = {
        # dark mode
        AppleInterfaceStyle = "Dark";
        NSTableViewDefaultSizeMode = 1;
        _HIHideMenuBar = true;
      };
      finder = {
        # start search in current directory
        FXDefaultSearchScope = "SCcf";
        # dont show warning when changing extension
        FXEnableExtensionChangeWarning = false;
        # finder view to list view
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
      };
      screencapture.location = "/tmp";
      # Bluetooth control on the top bar
      controlcenter.Bluetooth = true;
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    activationScripts.postActivation.text = ''
      # Disable Dock icons bouncing
      defaults write com.apple.dock no-bouncing -bool "true"

      # Disable all the hot corners
      defaults write com.apple.dock wvous-tl-corner -int 0
      defaults write com.apple.dock wvous-tr-corner -int 0
      defaults write com.apple.dock wvous-bl-corner -int 0
      defaults write com.apple.dock wvous-br-corner -int 0

      # disable .DS_Store
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool "true"

      # dont try and rebuild window state and relaunch apps after reboot
      defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool "false"
      defaults write com.apple.loginwindow TALLogoutSavesState -bool "false"
      defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool "false"
    '';
  };

  # dont respond to ping or icmp requests
  networking.applicationFirewall.enableStealthMode = true;
}
