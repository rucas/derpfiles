{ config, lib, pkgs, ... }:

let
  inherit (lib) mkMerge optionalAttrs listToAttrs;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
  extensions = [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock
    "fmkadmapgofadopljbjfkapdkoienihi" # React Dev Tools
    "dcpihecpambacapedldabdbpakmachpb" # Bypass Paywalls
    "chklaanhfefbnpoihckbnefhakgolnmc" # JSONVue
    "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
    "lmpnkcilhkcnpjbmdnkbepmlhjlnhkaf" # Isengard
  ];
in mkMerge [
  (optionalAttrs isLinux {
    programs.chromium = {
      # chromium isn't built for darwin so we'll want to avoid enabling it.
      enable = true;
      extensions = extensions;
    };
  })

  (optionalAttrs isDarwin (let
    configDir = "Library/Application Support/Google/Chrome";
    extensionJson = ext: {
      name = "${configDir}/External Extensions/${ext}.json";
      value.text = builtins.toJSON {
        external_update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  in { home.file = listToAttrs (map extensionJson extensions); }))
]
