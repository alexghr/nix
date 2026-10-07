{
  description = "alexghr's nix configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Last working libfido2 build for Palpatine's resident SSH keys.
    nixpkgs-fido.url = "github:NixOS/nixpkgs/7fc6f2c20af09cdcaf48b92ec3121860139ec668";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agents = {
      url = "github:alexghr/agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    website = {
      url = "git+ssh://git@github.com/alexghr/alexghr.me?ref=main";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./modules
      ];
      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
      flake = {
        nixosModules.agenix = inputs.agenix.nixosModules.default;
        nixosModules.disko = inputs.disko.nixosModules.default;
        nixosModules.alexghr-me = import "${inputs.website}/nix/module.nix";
        darwinModules.agenix = inputs.agenix.darwinModules.default;
      };
    };
}
