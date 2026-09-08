{
  config,
  pkgs,
  lib,
  alexghrKeys,
  modulesPath,
  nixosModules,
  ...
}: {
  imports = [
    nixosModules.systemd-boot
    nixosModules.btrfs
    nixosModules.zram
    nixosModules.nix
    nixosModules.system-tools
    nixosModules.agenix
    "${modulesPath}/installer/scan/not-detected.nix"
    ./trip.fs.nix
    ./services
  ];

  system.stateVersion = "23.11";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Temporary exception until the NixOS 26.05 upgrade.
  nixpkgs.config.permittedInsecurePackages = ["docker-28.5.2"];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel" "coretemp" "msr"];
    kernelParams = ["pcie_aspm=force"];
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
    };

    # keep getting hung tasks. Panic and restart system after 1 second
    # https://unix.stackexchange.com/questions/702983/automatically-restart-linux-on-hung-task-timeout-dmesg
    kernel.sysctl = {
      "kernel.hung_task_panic" = 1;
      "kernel.panic" = 1;
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;

  users.users.root.openssh.authorizedKeys.keys = alexghrKeys;

  environment.systemPackages = with pkgs; [
    git
    config.boot.kernelPackages.turbostat
    virt-manager
    libguestfs
  ];

  networking = {
    hostName = "trip";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        21064 # home-assistant's homekit integration
      ];
    };

    bridges = {
      "br0" = {
        interfaces = ["enp3s0"];
      };
    };

    interfaces.br0 = {
      useDHCP = true;
    };
  };

  age.secrets = {
    tailscale.file = ./secrets/tailscale.age;
  };

  services = {
    openssh.enable = true;
    fwupd.enable = true;
    thermald.enable = true;
    # Remove one of the Intel i226-V NICs (in this case, eth0)
    # both eth0 and eth1 cause the system to hang when power management is enabled
    # if there is no cable plugged in
    udev = {
      enable = true;
      extraRules = let
        eth0 = "0000:02:00.0";
        disableEth0 = pkgs.writeShellScript "disable-eth0" ''
          echo 1 > /sys/bus/pci/devices/0000:02:00.0/remove
          echo Removed PCI device ${eth0}
        '';
      in ''ACTION=="add", SUBSYSTEM=="pci", KERNEL=="${eth0}", RUN+="${disableEth0}"'';
    };

    avahi = {
      enable = true;
      reflector = true;
      nssmdns4 = true;
      allowInterfaces = ["enp3s0"];
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
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
    script = ''
      ${pkgs.nvme-cli}/bin/nvme set-feature /dev/nvme0n1 --feature-id 0x10 --value=0x01430152 --save --namespace-id 0xffffffff
    '';
  };

  virtualisation = {
    docker = {
      enable = true;
    };
    oci-containers.backend = "docker";
    libvirtd = {
      enable = true;
    };
  };
}
