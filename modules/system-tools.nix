{...}: let
  common = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [curl file jq ripgrep lsof];
  };
in {
  flake.nixosModules.system-tools = {pkgs, ...}: {
    imports = [common];
    environment.systemPackages = with pkgs; [
      vim
      powertop
      pciutils
      usbutils
      dnsutils
    ];
  };
  flake.darwinModules.system-tools = common;
}
