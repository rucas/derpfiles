{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:

buildHomeAssistantComponent rec {
  owner = "raman325";
  domain = "lock_code_manager";
  version = "8.1.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "lock_code_manager";
    tag = version;
    hash = "sha256-YMEXlEoxbMdBUqRGAaOGwgbzPZ9JAPWw1/5PbMPYPuo=";
  };

  # Upstream stamps the real version into the manifest only in its release
  # zip; the tagged source carries a 0.0.0 placeholder.
  postPatch = ''
    substituteInPlace custom_components/lock_code_manager/manifest.json \
      --replace-fail '"version": "0.0.0"' '"version": "${version}"'
  '';

  # providers/__init__.py imports the ZHA provider unconditionally, so the
  # config flow needs zigpy even on a host that never runs ZHA.
  dependencies = [ python3Packages.zigpy ];

  meta = {
    description = "Manage lock user codes across Z-Wave, Zigbee and Matter locks";
    homepage = "https://github.com/raman325/lock_code_manager";
    license = lib.licenses.mit;
  };
}
