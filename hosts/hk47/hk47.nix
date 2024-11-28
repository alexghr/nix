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
    nixosModules.agenix
    "${modulesPath}/installer/scan/not-detected.nix"
    ./hk47.fs.nix
  ];
  system.stateVersion = "21.05";
  time.timeZone = "Europe/London";

  boot = {
    kernelParams = ["cma-256M"];
    kernelPackages = pkgs.linuxPackages_6_1;

    initrd.availableKernelModules = ["xhci_pci" "usb_storage" "usbhid"];
    initrd.kernelModules = [];
    kernelModules = [];
    extraModulePackages = [];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = false;
    };

    # custom /tmp in filesystems
    # I needed more storage in order for nix to be able to build things
    # default tmpOnTmpfs allocates 50% of RAM, which is 2GiB on this system
    tmp.useTmpfs = false;
  };

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
    useDHCP = false;
    hostName = "hk47";
    networkmanager.enable = false;
    wireless = {
      enable = false;
      interfaces = ["wlan0"];
    };

    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    firewall.enable = true;
  };

  age.secrets = {
    tailscale.file = ./secrets.tailscale.age;
  };

  users.mutableUsers = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    powertop
    lsof
    lm_sensors
    pciutils
    raspberrypi-eeprom
    libraspberrypi
  ];

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets.tailscale.path;
    };
  };
}
