{
  config,
  pkgs,
  packages,
  lib,
  alexghrKeys,
  modulesPath,
  nixosModules,
  ...
}: {
  imports = [
    nixosModules.nix
    "${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"
  ];

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.hostPlatform.system = "armv6l-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux";

  system.stateVersion = "23.11";
  time.timeZone = "Europe/London";

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  powerManagement = {
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  users.users.root.openssh.authorizedKeys.keys = alexghrKeys;

  networking = {
    hostName = "mse-6";
    networkmanager.enable = true;
    wireless.enable = false;
    firewall.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    lsof
    libraspberrypi
  ];

  services = {
    openssh.enable = true;
  };
}
