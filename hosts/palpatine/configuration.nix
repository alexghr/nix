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
    nixosModules.disko
    "${modulesPath}/installer/scan/not-detected.nix"
    ./disko-config.nix
    ./swap.nix
    ./x.nix
    ./ag
  ];

  system.stateVersion = "24.05";
  # inspired from https://github.com/caarlos0/dotfiles/blob/e2cb05d1e381956b7aba4303cc27206695657a0e/machines/shared.nix#L83
  #nix.extraOptions = ''
  #  post-build-hook = ${packages.uploadToCache}/bin/upload-to-cache
  #'';

  age.secrets.nix-ssh.file = ./secrets/nix-ssh.age;
  programs.ssh.extraConfig = ''
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
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    useDHCP = false;
    dhcpcd.enable = false;
    interfaces.enp5s0.wakeOnLan = {
      enable = true;
      policy = ["magic"];
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
    };
    appimage = {
      enable = true;
      binfmt = true;
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
  };

  security.rtkit.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      extraOptions = "--registry-mirror https://docker.esrever.uno";
    };

    oci-containers.backend = "docker";
  };

  environment.systemPackages = with pkgs.unstable; [
    packages.uploadToCache
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
