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
    nixosModules.kmonad
    nixosModules.disko
    "${modulesPath}/installer/scan/not-detected.nix"
    ./disko-config.nix
    ./swap.nix
    ./x.nix
    ./ag
  ];

  system.stateVersion = "24.05";

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
    pulseaudio.enable = false; # uses pipewire instead
    bluetooth.enable = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

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

    kmonad = {
      enable = false;
      keyboards.homerowMods = let
        device = "/dev/input/by-id/usb-DREVO.Inc_BladeMaster_PRO_88-if01-event-kbd";
      in {
        inherit device;
        config = builtins.readFile ./kmonad.kbd;
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
