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

  system.activationScripts.postActivation.text = ''
    # Disable Dock icons bouncing
    defaults write com.apple.dock no-bouncing -bool true
  '';
}
