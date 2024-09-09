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
    ./fs.nix
    ./swap.nix
    ./x.nix
    ./ag
  ];

  system.stateVersion = "22.11";

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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
    pulseaudio.enable = false; # uses pipewire instead
    bluetooth.enable = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    kernelPackages = pkgs.linuxPackages_6_9;
    kernelModules = ["kvm-amd"];
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  networking = {
    hostName = "palpatine";
    networkmanager.enable = true;
    wireless.enable = false;
    firewall.enable = true;
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
    };
  };

  age.secrets.tailscale.file = ./secrets/tailscale.age;

  services = {
    gvfs.enable = true;
    fstrim.enable = true;
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
      authKeyFile = config.age.secrets.tailscale.path;
    };

    avahi = {
      enable = true;
      allowInterfaces = ["enp5s0"];
      publish = {
        workstation = true;
      };
    };
  };

  security.rtkit.enable = true;

  virtualisation = {
    docker.enable = true;
    oci-containers.backend = "docker";
  };

  environment.systemPackages = with pkgs.unstable; [
    nix-output-monitor
    nvd
    nh
    neovim
    git
    curl
    powertop
    lm_sensors
    pciutils
    usbutils
    dnsutils
    lsof
    ripgrep
    bat
    file
    ntfs3g
  ];
  environment.loginShellInit = ''
    alias vim=nvim
  '';
}
