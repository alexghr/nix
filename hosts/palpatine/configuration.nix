{
  config,
  pkgs,
  lib,
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
    nixosModules.disko
    "${modulesPath}/installer/scan/not-detected.nix"
    ./disko-config.nix
    ./x.nix
    ./ag
    ./vm.nix
  ];

  system.stateVersion = "24.05";
  age.secrets.nix-ssh.file = ./secrets/nix-ssh.age;
  programs.ssh.extraConfig = lib.optionalString (config.age.secrets ? nix-ssh) ''
    Host nixcache.esrever.uno
    User nix-ssh
    BatchMode yes
    IdentitiesOnly yes
    IdentityFile ${config.age.secrets.nix-ssh.path}
  '';

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    keyboard.qmk.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = false;
      powerManagement.enable = true;
      nvidiaSettings = true;
      modesetting.enable = true;
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    ledger.enable = true;

    enableAllFirmware = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "uinput"];
    kernelPackages = pkgs.linuxPackages;
    kernelModules = ["kvm-amd"];
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  networking = {
    hostName = "palpatine";
    networkmanager.enable = true;
    wireless.enable = false;
    firewall = {
      enable = true;
      allowPing = true;
    };
    useDHCP = false;
    dhcpcd.enable = false;
    interfaces.enp5s0.wakeOnLan = {
      enable = true;
      policy = ["magic"];
    };

    interfaces.enp6s0 = {
      useDHCP = true;
    };
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  programs = {
    dconf.enable = true;
    nm-applet.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      enableBrowserSocket = false;
      settings = {
        max-cache-ttl = 604800;
        default-cache-ttl = 604800;
      };
      pinentryPackage = pkgs.pinentry-all;
    };
  };

  age.secrets.tailscale.file = ./secrets/tailscale.age;

  services = {
    gvfs.enable = true;
    openssh.enable = true;
    fwupd.enable = true;
    dbus.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
      authKeyFile =
        if config.age.secrets ? tailscale
        then config.age.secrets.tailscale.path
        else null;
    };
  };

  security.rtkit.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      extraOptions = "--registry-mirror https://docker.esrever.uno";
      package = pkgs.unstable.docker;
    };

    oci-containers.backend = "docker";
  };

  environment.systemPackages = [pkgs.ntfs3g];
}
