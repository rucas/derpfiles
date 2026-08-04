{
  description = "The original derpfiles flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-1password = {
      url = "github:yardnsm/tmux-1password";
      flake = false;
    };
    spacebar = {
      # Pins its own nixpkgs: the build references darwin.apple_sdk_11_0,
      # removed from nixpkgs-unstable, so it cannot follow root.
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
      inputs.nixpkgs.follows = "nixpkgs";
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
    gitui = {
      url = "github:gitui-org/gitui";
      flake = false;
    };
    claude-code-safety-net = {
      url = "github:kenryu42/claude-code-safety-net";
      flake = false;
    };
    i-have-adhd = {
      url = "github:ayghri/i-have-adhd";
      flake = false;
    };
    rucaslab = {
      url = "github:rucas/rucaslab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      pre-commit-hooks,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/hosts.nix
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          system,
          self',
          ...
        }:
        let
          pkgs = import nixpkgs {
            localSystem.system = system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
          inherit (pkgs.stdenv) isDarwin;
        in
        {
          _module.args.pkgs = pkgs;

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              prettier.enable = true;
              shfmt.enable = true;
              taplo.enable = true;
            };
            # Leave hand-maintained prose docs alone; format data/config only.
            settings.formatter.prettier.excludes = [ "*.md" ];
            # git-crypt-encrypted files are opaque blobs when locked; never format them.
            settings.global.excludes = [ "secrets/**" ];
          };

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = builtins.path {
                path = ./.;
                name = "source";
              };
              hooks = {
                statix = {
                  enable = true;
                  settings.ignore = [ ".direnv" ];
                };
                deadnix.enable = true;
                treefmt = {
                  enable = true;
                  package = config.treefmt.build.wrapper;
                };
              };
            };
          };

          devShells.default = pkgs.mkShell {
            inherit (self'.checks.pre-commit-check) shellHook;
            packages = [
              pkgs.just
              pkgs.nixd
              pkgs.statix
              pkgs.deadnix
            ];
          };

          packages = {
            inherit (pkgs) claude-code cc-safety-net gitui;
            inherit (pkgs.tmuxPlugins) tmux-1password tmux-pomodoro-plus;
          }
          // pkgs.lib.optionalAttrs isDarwin {
            inherit (pkgs) yabai;
          };
        };

      # Declarative host configurations
      hosts = {
        blkmrkt = {
          username = "lucas";
          arch = "aarch64-darwin";
          env = "darwin";
        };
        lronden-m-vy79p = {
          username = "lucas.rondenet";
          arch = "aarch64-darwin";
          env = "darwin";
        };
        salus = {
          username = "lucas";
          arch = "aarch64-darwin";
          env = "darwin";
        };
        rucaslab = {
          username = "lucas";
          arch = "x86_64-linux";
          env = "nixos";
        };
      };

      flake = {
        overlays.default = import ./overlays/default.nix { inherit self inputs; };
      };
    };
}
