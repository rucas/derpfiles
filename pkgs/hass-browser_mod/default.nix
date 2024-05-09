{ fetchFromGitHub, buildHomeAssistantComponent }:

buildHomeAssistantComponent rec {

  owner = "thomasloven";
  domain = "browser_mod";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = owner;
    repo = "hass-browser_mod";
    rev = "91741384df2dd2271c459e3c992bc04c814cee52";
    hash = "sha256-XGHE1/z0tMMjxQv4l/8jT2niWAumEw4iPf4gLOrp7/Y=";
  };
}
