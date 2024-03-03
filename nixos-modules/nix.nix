{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.nix = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
    nixpkgs.overlays = [(final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = prev.config.allowUnfree;
      };
    })];
    nix = {
      package = lib.mkDefault pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      gc = {
        automatic = true;
        dates = "monthly";
        options = "--delete-older-than 30d";
      };

      nixPath = [
        "nixpkgs=/etc/nixpkgs/channels/nixpkgs"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ /etc/nixpkgs/channels/nixpkgs - - - - ${inputs.nixpkgs}"
    ];
  };
}
