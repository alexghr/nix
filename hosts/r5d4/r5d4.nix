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
    nixosModules.systemd-boot
    nixosModules.agenix
    "${modulesPath}/installer/scan/not-detected.nix"
    ./r5d4.fs.nix
  ];

  system.stateVersion = "23.11";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "coretemp"];
  boot.extraModulePackages = [];

  age.secrets = {
    tailscale.file = ./secrets.tailscale.age;
  };

  users.users.root.openssh.authorizedKeys.keys = alexghrKeys;

  environment.systemPackages = with pkgs; [
    vim
    git
    powertop
    lsof
    lm_sensors
    pciutils
  ];

  networking = {
    hostName = "r5d4";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      trustedInterfaces = [];
      allowedTCPPorts = [
        8443 # unifi https port
        21064 # home-assistant's homekit integration
      ];
      allowedUDPPorts = [];
    };
  };

  services = {
    openssh.enable = true;
    thermald.enable = true;
    home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        # Components required to complete the onboarding
        "zha"
        "met"
        "homekit"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
        "automation ui" = "!include automations.yaml";
      };
    };

    avahi = {
      enable = true;
      reflector = true;
      nssmdns = true;
      allowInterfaces = ["wlp2s0"];
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    unifi = {
      enable = true;
      unifiPackage = pkgs.unifi7;
      openFirewall = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets.tailscale.path;
    };
  };

  # https://discourse.nixos.org/t/fan-keeps-spinning-with-a-base-installation-of-nixos/1394/3?u=alexghr
  environment.etc."sysconfig/lm_sensors".text = ''
    # Generated by sensors-detect on Mon Feb 12 22:47:21 2024
    # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
    # be loaded/unloaded.
    #
    # The format of this file is a shell script that simply defines variables:
    # HWMON_MODULES for hardware monitoring driver modules, and optionally
    # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

    HWMON_MODULES="coretemp"
  '';
}