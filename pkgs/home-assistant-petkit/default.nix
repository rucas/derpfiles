{ pkgs, fetchFromGitHub, buildHomeAssistantComponent, petkitaio }:

buildHomeAssistantComponent rec {

  owner = "RobertD502";
  domain = "petkit";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = owner;
    repo = "home-assistant-petkit";
    rev = "ad09c6579b2c41bfd63104d3859772fc32c5e4c5";
    hash = ''
      sha256-Xun/djFEqzwslNmZgXbdjDtvKdUFZq8fx1aKfGlUdow=
    '';
  };
  propagatedBuildInputs = [ pkgs.python311Packages.tzlocal petkitaio ];
}
