{
  description = "The original derpfiles flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
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
    };
    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
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
      url = "github:extrawurst/gitui";
      flake = false;
    };
    claude-code-safety-net = {
      url = "github:kenryu42/claude-code-safety-net";
      flake = false;
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
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
      ];

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, self', ... }:
        let
          pkgs = import nixpkgs {
            localSystem.system = system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
          inherit (pkgs.stdenv) isDarwin;
        in
        {
          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = builtins.path {
                path = ./.;
                name = "source";
              };
              hooks = {
                statix.enable = true;
                nixfmt.enable = true;
              };
            };
          };

          formatter = pkgs.nixfmt;

          devShells.default = pkgs.mkShell {
            inherit (self'.checks.pre-commit-check) shellHook;
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
        c889f3b8f7d7 = {
          username = "awslucas";
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
