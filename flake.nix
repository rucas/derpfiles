{
  description = "The original derpfiles flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
    };
    golink = {
      url = "github:tailscale/golink";
    };
    tmux-1password = {
      url = "github:yardnsm/tmux-1password";
      flake = false;
    };
    spacebar = {
      url = "github:cmacrae/spacebar";
    };
    fast-syntax-highlighting = {
      url = "github:zdharma-continuum/fast-syntax-highlighting";
      flake = false;
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/nur";
    };
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    english-words = {
      url = "github:dwyl/english-words";
      flake = false;
    };
    git-alias = {
      url = "github:GitAlias/gitalias";
      flake = false;
    };
    kube-aliases = {
      url = "github:Dbz/kube-aliases";
      flake = false;
    };
    nxvm = {
      url = "github:rucas/nxvm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-pomodoro-plus = {
      url = "github:olimorris/tmux-pomodoro-plus";
      flake = false;
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      agenix,
      nix-darwin,
      golink,
      home-manager,
      flake-parts,
      spacebar,
      alacritty-theme,
      nur,
      nxvm,
      opnix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
          isDarwin = pkgs.stdenv.isDarwin;
        in
        {
          packages = {
            claude-code = pkgs.claude-code;
            inherit (pkgs.tmuxPlugins) tmux-1password tmux-pomodoro-plus;
          }
          // pkgs.lib.optionalAttrs isDarwin {
            yabai = pkgs.yabai;
          };
        };

      flake =
        let
          inherit (nixpkgs) lib;
          inherit (builtins) fromTOML readFile;
          mkHost =
            {
              host,
              username,
              arch,
              env ? "darwin",
            }:
            let
              isDarwin = if env == "darwin" then true else false;
              isNixOs = !isDarwin;
            in
            {
              darwin = nix-darwin.lib.darwinSystem;
              nixos = nixpkgs.lib.nixosSystem;
            }
            .${env}
              {
                system = arch;
                specialArgs = {
                  CONF = fromTOML (readFile ./hosts/configs.toml);
                  inherit inputs;
                };
                modules = [
                  {
                    nixpkgs.config = {
                      allowUnfree = true;
                      permittedInsecurePackages = [ "openssl-1.1.1w" ];
                    };
                    nixpkgs.overlays = [
                      self.overlays.default
                      alacritty-theme.overlays.default
                      golink.overlays.default
                      spacebar.overlay
                      nur.overlays.default
                    ];
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = {
                      inherit inputs;
                      theme = fromTOML (readFile ./modules/themes/gruvbox.toml);
                    };
                    home-manager.users.${username} = import ./hosts/${host}/home.nix;
                  }
                ]
                ++ lib.optionals isDarwin [
                  ./hosts/${host}/darwin.nix
                  opnix.darwinModules.default
                  ./hosts/${host}/secrets.nix
                  home-manager.darwinModules.home-manager
                ]
                ++ lib.optionals isNixOs [
                  golink.nixosModules.default
                  ./hosts/${host}/configuration.nix
                  home-manager.nixosModules.home-manager
                  agenix.nixosModules.default
                  opnix.nixosModules.default
                ];
              };
        in
        {
          overlays.default = import ./overlays/default.nix { inherit self inputs; };

          darwinConfigurations = {
            blkmrkt = mkHost {
              host = "blkmrkt";
              username = "lucas";
              arch = "aarch64-darwin";
              env = "darwin";
            };

            c889f3b8f7d7 = mkHost {
              host = "c889f3b8f7d7";
              username = "awslucas";
              arch = "aarch64-darwin";
              env = "darwin";
            };

            "lronden-m-vy79p" = mkHost {
              host = "lronden-m-vy79p";
              username = "lucas.rondenet";
              arch = "aarch64-darwin";
              env = "darwin";
            };

            salus = mkHost {
              host = "salus";
              username = "lucas";
              arch = "aarch64-darwin";
              env = "darwin";
            };
          };

          nixosConfigurations = {
            rucaslab = mkHost {
              host = "rucaslab";
              username = "lucas";
              arch = "x86_64-linux";
              env = "nixos";
            };
          };
        };
    };
}
