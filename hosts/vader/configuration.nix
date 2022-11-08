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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    #loader.efi.efiSysMountPoint = "/boot/efi";

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
  };

  networking = {
    hostName = "vader";
    networkmanager.enable = false;
    wireless.enable = false;

    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;

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
    package = pkgs.nixVersions.nix_2_8;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  programs.dconf.enable = true;

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

  environment.systemPackages = with pkgs; [
    pinentry
    pinentry-curses
    ntfs3g
    lm_sensors
    android-tools
    yubikey-manager
    gamemode
    dxvk
    xwayland
    pkgs.unstable.ledger-live-desktop
    tailscale
    sshfs
  ];

  programs.steam = {
    enable = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
    screenSection = ''
      Option "metamodes" "3840x1600_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
    '';
    displayManager.defaultSession = "none+i3";
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        dunst
        shutter
        maim
        simplescreenrecorder
      ];
    };

    desktopManager.xterm.enable = true;
  };

  services.blueman.enable = true;

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

  services.vscode-server.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  virtualisation.lxd.enable = true;

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

  age.secrets.tailscale = {
    file = ../../secrets/vader.tailscale.age;
  };
  services.tailscale.enable = true;

  # taken from https://tailscale.com/blog/nixos-minecraft/
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey file:${config.age.secrets.ag-npmrc.path} --advertise-exit-node
    '';
  };

  # enable IP forwarding so this machine can be a Tailscale exit node
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}

