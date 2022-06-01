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

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
      nvidiaSettings = true;
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
    wireless.enable = false;

    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;

    firewall.enable = true;
    firewall.allowedTCPPorts = [
      3000
    ];
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
    pinentryFlavor = "gnome3";
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
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.hue-lights
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.gamemode
    gnome.gnome-tweaks
    yubikey-manager
    gamemode
    dxvk
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
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  services.udev.packages = [pkgs.gnome3.gnome-settings-daemon];

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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  alexghr.restic.b2 = {
    enable = true;
    bucket = "alexghr-backup";
    when = "09:00";
  };
}

