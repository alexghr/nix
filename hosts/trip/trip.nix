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
    nixosModules.systemd-boot
    nixosModules.btrfs
    nixosModules.nix
    nixosModules.agenix
    "${modulesPath}/installer/scan/not-detected.nix"
    ./trip.fs.nix
  ];

  system.stateVersion = "23.11";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel" "coretemp"];
    extraModulePackages = [];
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
      kernelModules = [];
    };

    # keep getting hung tasks. Panic and restart system after 1 second
    # https://unix.stackexchange.com/questions/702983/automatically-restart-linux-on-hung-task-timeout-dmesg
    kernel.sysctl = {
      "kernel.hung_task_panic" = 1;
      "kernel.panic" = 1;
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";

  users.users.root.openssh.authorizedKeys.keys = alexghrKeys;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    powertop
    lm_sensors
    pciutils
    usbutils
  ];

  networking = {
    hostName = "trip";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        8443 # unifi https port
        21064 # home-assistant's homekit integration
      ];
      allowedUDPPorts = [];
    };
  };

  age.secrets = {
    tailscale.file = ./secrets.tailscale.age;
  };

  services = {
    openssh.enable = true;
    fwupd.enable = true;
    thermald.enable = true;

    home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
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
      allowInterfaces = ["enp3s0"];
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    unifi = {
      enable = true;
      unifiPackage = pkgs.unifi7;
      mongodbPackage = pkgs.pinned.mongodb-4_4;
      openFirewall = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      extraUpFlags = ["--advertise-exit-node"];
      authKeyFile = config.age.secrets.tailscale.path;
    };
    iperf3.enable = true;
  };

  systemd.services.set-nvme-temp = {
    description = "Set NVMe temperature limit";
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";

    # https://discourse.nixos.org/t/psa-keep-nvme-storage-devices-from-getting-too-hot/35830
    # set thermal limits for NVMe SSD to throttle instead of reaching critical temperature
    # Temp 1 - 50C
    # Temp 2 - 65C
    # encoded as a hex string (see above thread) and set on the default namespace
    # find out namespace-id with nvme smart-log /dev/nvme0n1
    script = with pkgs; ''
      ${pkgs.nvme-cli}/bin/nvme set-feature /dev/nvme0n1 --feature-id 0x10 --value=0x01430152 --save --namespace-id 0xffffffff
    '';
  };

  # https://discourse.nixos.org/t/fan-keeps-spinning-with-a-base-installation-of-nixos/1394/3?u=alexghr
  environment.etc."sysconfig/lm_sensors".text = ''
    # Generated by sensors-detect on Sat Mar  2 21:48:29 2024
    # This file is sourced by /etc/init.d/lm_sensors and defines the modules to
    # be loaded/unloaded.
    #
    # The format of this file is a shell script that simply defines variables:
    # HWMON_MODULES for hardware monitoring driver modules, and optionally
    # BUS_MODULES for any required bus driver module (for example for I2C or SPI).

    HWMON_MODULES="coretemp"
  '';
}
