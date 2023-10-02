# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: let username = "ag"; in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware = {
    enableAllFirmware = true;
    pulseaudio.enable = false; # uses pipewire instead
    bluetooth.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    #loader.efi.efiSysMountPoint = "/boot/efi";

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
    enableContainers = true;

    # enable IP forwarding so this machine can be a Tailscale exit node
    kernel.sysctl."net.ipv4.ip_forward" = 1;

    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking = {
    hostName = "vader";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [3000];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # change this to enable Tailscale to act as an exit node
    firewall.checkReversePath = "loose";
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.nix_2_16;
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
  };

  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
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
  };

  programs.adb.enable = true;
  users.users.ag.extraGroups = ["adbusers"];

  environment.systemPackages = with pkgs; [
    pinentry
    pinentry-curses
    ntfs3g
    lm_sensors
    yubikey-manager
    gamemode
    dxvk
    xwayland
    pkgs.unstable.ledger-live-desktop
    tailscale
    sshfs
    pcmanfm
    graphite-kde-theme
    attic
    protontricks

    # KDE packages
    plasma5Packages.filelight
    plasma5Packages.kalk
    plasma5Packages.calindori
  ];

  services.dbus.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions="compose:menu";
    videoDrivers = [ "nvidia" ];
    enable = true;
    screenSection = ''
      Option "metamodes" "3840x1600_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
    '';
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.udev.packages = [
    pkgs.unstable.ledger-udev-rules
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "weekly";
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

  age.secrets.ghcr-token.file = ../../secrets/vader.ghcr.age;
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  virtualisation.lxd.enable = true;
  virtualisation.lxc.lxcfs.enable = true;

  age.secrets.restic-b2-password.file = ../../secrets/vader.restic-b2-password.age;
  alexghr.b2-backup = {
    enable = true;
    passwordFile = config.age.secrets.restic-b2-password.path;
    bucket = "alexghr-backup";
    when = "09:00";
  };

  age.secrets.ag-npmrc = {
    file = ../../secrets/ag.npmrc.age;
    owner = "ag";
    group = "users";
  };

  alexghr.nodejs.ag = {
    npmrc = config.age.secrets.ag-npmrc.path;
  };

  age.secrets.tailscale.file = ../../secrets/vader.tailscale.age;
  alexghr.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
    exitNode = true;
  };
}

