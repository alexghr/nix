{
  description = "alexghr's nix configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/809cca784b9f72a5ad4b991e0e7bcf8890f9c3a6";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-theme = {
      url = "github:alexghr/alacritty-theme.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wolhttp = {
      url = "github:alexghr/wolhttp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./modules
        ./packages
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages.default = pkgs.hello;
        packages.wolhttp = inputs.wolhttp.packages.${system}.default;
        formatter = pkgs.alejandra;
      };
      flake = {
        nixosModules.agenix = inputs.agenix.nixosModules.default;
        nixosModules.disko = inputs.disko.nixosModules.default;
        nixosModules.wolhttp = inputs.wolhttp.nixosModules.default;
        darwinModules.agenix = inputs.agenix.darwinModules.default;
        alexghrKeys = import ./alexghr.keys.nix;
      };
    };
}
