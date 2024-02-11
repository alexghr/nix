# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ nixpkgsFlakePath }:
{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.enableAllFirmware = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot = {
      enable = true;
      memtest86 = {
        enable = true;
        entryFilename = "o_memtest86.conf";
      };
    };

    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];

    # enable IP forwarding so this machine can be a Tailscale exit node
    kernel.sysctl."net.ipv4.ip_forward" = 1;

    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  networking = {
    hostName = "r5d4";
    networkmanager.enable = true;
    wireless.enable = false;

    firewall = {
      enable = true;
      # trustedInterfaces = ["tailscale0"];
      # allowedTCPPorts = [];
      # allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # change this to enable Tailscale to act as an exit node
    firewall.checkReversePath = "loose";
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

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

    nixPath = [
      "nixpkgs=/etc/nixpkgs/channels/nixpkgs"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ /etc/nixpkgs/channels/nixpkgs - - - - ${nixpkgsFlakePath}"
  ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "daily";
  };

  services.fstrim.enable = true;
  services.openssh.enable = true;
  security.rtkit.enable = true;
  services.fwupd.enable = true;

  powerManagement.powertop.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
  ];

  # age.secrets.tailscale.file = ../../secrets/palpatine.tailscale.age;
  # alexghr.tailscale = {
  #   enable = true;
  #   authKeyFile = config.age.secrets.tailscale.path;
  #   exitNode = true;
  # };

  environment.systemPackages = with pkgs; [
    vim
    git
    powertop
  ];
}

