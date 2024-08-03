# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{nixpkgsFlakePath}: {
  config,
  pkgs,
  lib,
  ...
}: let
  username = "ag";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware = {
    enableAllFirmware = true;
    pulseaudio.enable = false; # uses pipewire instead
    bluetooth.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
      nvidiaSettings = true;
      modesetting.enable = true;
    };

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };

    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = ["btrfs"];
    enableContainers = true;

    # enable IP forwarding so this machine can be a Tailscale exit node
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;

      # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    #binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking = {
    hostName = "palpatine";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      trustedInterfaces = ["lxdbr0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-24.8.6"
    ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    settings = {
      extra-trusted-users = ["ag"];
    };

    nixPath = [
      "nixpkgs=/etc/nixpkgs/channels/nixpkgs"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /etc/nixpkgs/channels/nixpkgs - - - - ${nixpkgsFlakePath}"
  ];

  programs.dconf.enable = true;
  programs.nm-applet.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  programs.ssh = {
    extraConfig = ''
      Host *.alexghr.me
        ForwardAgent yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra

      Host *.home
        ForwardAgent yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.adb.enable = true;
  users.users.ag.extraGroups = ["adbusers"];

  environment.systemPackages = with pkgs; [
    pinentry
    pinentry-qt
    ntfs3g
    lm_sensors
    yubikey-manager
    gamemode
    dxvk
    xwayland
    pkgs.unstable.ledger-live-desktop
    tailscale
    sshfs
    attic
    protontricks
    nnn
    file
    cifs-utils
    samba
    earthly
    btop
    pkgs.unstable.neovide
    pkgs.unstable.neovim
    kwalletmanager
    kwalletcli
    #starship
  ];
  programs.starship = {
    enable = true;
    presets = ["pure-preset"];
    settings = {
      add_newline = false;
    };
  };

  services.gvfs.enable = true;
  services.dbus = {
    enable = true;
    packages = [pkgs.kwalletmanager pkgs.kdePackages.kwallet];
  };
  services.avahi = {
    enable = true;
    allowInterfaces = ["eth0"];
    publish = {
      workstation = true;
    };
  };

  services.xserver = {
    xkb.layout = "us";
    xkb.options = "compose:menu";
    videoDrivers = ["nvidia"];
    enable = true;
    screenSection = ''
      Option "metamodes" "3840x1600_144 +0+0 {ForceCompositionPipeline=Off, ForceFullCompositionPipeline=Off, AllowGSYNCCompatible=On}"
    '';
    updateDbusEnvironment = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        qimgv
        llpp
        dmenu
        i3status
        i3lock
        dunst
        maim
        dex
        simplescreenrecorder
        rofi
        rofi-calc
        pcmanfm
        pkgs.unstable.neovide
      ];
    };

    desktopManager.xterm.enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  zramSwap.enable = true;

  systemd.oomd = {
    enable = lib.mkForce true;
  };

  # apply diff from https://github.com/NixOS/nixpkgs/pull/273921
  systemd.slices."-".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "80%";
  };

  systemd.slices."system".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "80%";
  };

  systemd.slices."user-".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "80%";
  };

  systemd.user.units."slice" = {
    text = ''
      ManagedOOMMemoryPressure=kill
      ManagedOOMMemoryPressureLimit=80%
    '';
    overrideStrategy = "asDropin";
  };

  systemd.user.services = {
    kwallet = {
      after = ["basic.target"];
      wantedBy = ["graphical-session.target"];
      script = ''
        ${pkgs.kdePackages.kwallet}/bin/kwalletd6
      '';
    };
  };

  services.udev.packages = [
    pkgs.unstable.ledger-udev-rules
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
    interval = "daily";
  };

  services.fstrim.enable = true;
  services.openssh.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pcscd.enable = true;

  services.fwupd.enable = true;

  services.vscode-server.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.lxd.enable = false;
  virtualisation.lxc.lxcfs.enable = false;

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.aztec-devbox = {
    image = "aztecprotocol/devbox:1.0";
    hostname = "aztec-devbox";
    #user = "root";
    autoStart = true;
    extraOptions = ["--network=host" "--privileged"];
    volumes = [
      "/home/ag/code/aztec:/workspaces"
    ];
    #entrypoint = "/bin/bash";
    cmd = ["/bin/bash" "-c" "while true; do sleep 1; done"];
    #cmd = ["sleep" "9999"];
  };

  virtualisation.oci-containers.containers.aztec-sysbox = {
    image = "ghcr.io/alexghr/aztec-sysbox:latest";
    hostname = "aztec-sysbox";
    #user = "root";
    autoStart = true;
    extraOptions = ["--privileged"];
    volumes = [
      "/home/ag/code/aztec:/workspaces"
      "user:/home/ubuntu"
    ];
    #entrypoint = "/bin/bash";
    #cmd = ["/bin/bash" "-c" "while true; do sleep 1; done"];
    #cmd = ["sleep" "9999"];
  };

  # age.secrets.restic-b2-password.file = ../../secrets/vader.restic-b2-password.age;
  # alexghr.b2-backup = {
  #   enable = true;
  #   passwordFile = config.age.secrets.restic-b2-password.path;
  #   bucket = "alexghr-backup";
  #   when = "09:00";
  # };

  # age.secrets.ag-npmrc = {
  #   file = ../../secrets/ag.npmrc.age;
  #   owner = "ag";
  #   group = "users";
  # };

  # alexghr.nodejs.ag = {
  #   npmrc = config.age.secrets.ag-npmrc.path;
  # };

  age.secrets.tailscale.file = ../../secrets/palpatine.tailscale.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale.path;
  };

  age.secrets.ag-samba.file = ../../secrets/ag.samba.age;

  #programs.neovim = {
  #  enable = true;
  #  package = pkgs.unstable.neovim;
  #  configure = {
  #  };
  #};

  #fonts.packages = [pkgs.fira-code]
}
