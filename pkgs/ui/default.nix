{ pkgs, fetchFromGitHub, buildHomeAssistantComponent }:
buildHomeAssistantComponent rec {
  owner = "UI-Lovelace-Minimalist";
  domain = "ui_lovelace_minimalist";
  version = "v1.3.9";

  propagatedBuildInputs =
    [ pkgs.python312Packages.aiofiles pkgs.python312Packages.aiogithubapi ];

  src = fetchFromGitHub {
    owner = owner;
    repo = "UI";
    rev = version;
    hash = "sha256-zspPC8z4TaUi3/Qjz8Z6nbV6o4DcslR6Hvm17cvLhXA=";
  };

  patches = [ ../../patches/ui_lovelace_minimalist/aiofiles.patch ];
}
