# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.supportedFilesystems = ["btrfs"];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.timeout = 10;

  networking.hostName = "nix-1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp7s0.useDHCP = true;

  nix = {
    package = pkgs.nixVersions.nix_2_7;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    k3s
    kubectl
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    enableExtraSocket = true;
  };

  programs.ssh = {
    startAgent = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];

  networking.firewall.interfaces.enp7s0.allowedTCPPorts = [6443];
  networking.firewall.trustedInterfaces = [
    "flannel.1"
    "cni0"
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?


  services.k3s.enable = true;
  services.k3s.role = "server";
  #services.k3s.extraFlags

  virtualisation = {
    podman.enable = true;
    podman.dockerCompat = true;
    podman.defaultNetwork.dnsname.enable = true;
  };

  alexghr.restic.b2 = {
    enable = true;
    bucket = "alexghr-backup";
    when = "00:05";
  };
}

