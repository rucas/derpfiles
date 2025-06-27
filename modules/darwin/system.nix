{ ... }: {

  system.defaults.dock.autohide = true;
  system.defaults.dock.show-recents = false;

  # dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # show only active in dock
  system.defaults.dock.static-only = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # finder start search in current directory
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  # dont show warning when changing extension
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  # finder view to list view
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";
  system.defaults.finder.ShowPathbar = true;

  system.defaults.NSGlobalDomain.NSTableViewDefaultSizeMode = 1;

  system.defaults.screencapture.location = "/tmp";

  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  # dont respond to ping or icmp requests
  networking.applicationFirewall.enableStealthMode = true;

  system.activationScripts.postActivation.text = ''
    # Disable Dock icons bouncing
    defaults write com.apple.dock no-bouncing -bool true

    # Disable all the hot corners
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-br-corner -int 0

    # disable .DS_Store
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
  '';
}
