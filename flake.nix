{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixvim,
    nixpkgs,
    self,
    pre-commit-hooks,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [pre-commit-hooks.flakeModule];

      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: let
        pkgs = import nixpkgs {inherit system;};
        nixvim' = nixvim.legacyPackages.${system};
        nvim = nixvim'.makeNixvimWithModule {
          inherit pkgs;
          module = import ./config;

          # extraSpecialArgs = {
          #   inherit self;
          # };
        };
      in {
        packages.default = nvim;

        pre-commit = {
          check.enable = true;

          settings.excludes = ["flake.lock"];

          settings.hooks = {
            alejandra.enable = true;
            commitizen.enable = true;
            nil.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            deadnix
            git
            nil
          ];

          DIRENV_LOG_FORMAT = "";
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;
      };
    };
}
