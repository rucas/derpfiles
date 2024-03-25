{ pkgs, lib, buildPythonPackage, fetchFromGitHub }:

buildPythonPackage rec {

  owner = "RobertD502";
  pname = "petkitaio";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = owner;
    repo = "petkitaio";
    rev = "50f5ff6689a07090e255a168099df852f9818cba";
    hash = ''
      sha256-zBr2EgkgUugDTeoYRKXfe0ZoxV0fkjz4wkmFIscypkg=
    '';
  };

  propagatedBuildInputs =
    [ pkgs.python311Packages.aiohttp pkgs.python311Packages.tzlocal ];

  doCheck = false;

  pythonImportsCheck = [ "petkitaio" ];

  meta = with lib; {
    description = "Asynchronous Python library for PetKit's API.";
    homepage = "https://github.com/RobertD502/petkitaio";
    license = licenses.mit;
    maintainers = with maintainers; [ rucas ];
  };
}
