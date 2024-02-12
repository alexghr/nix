# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ nixpkgsFlakePath }:
{ config, pkgs, lib, ... }:
let
  wakeVader = macPath: pkgs.writeShellScriptBin "wakevader" ''
    #!/usr/bin/env bash
    ${pkgs.wakeonlan}/bin/wakeonlan $(cat ${macPath})
  '';
in
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
      memtest86 = { enable = true;
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
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [8443];
      allowedUDPPorts = [ config.services.tailscale.port ];
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

  age.secrets = {
    tailscale.file = ../../secrets/r5d4.tailscale.age;
    vader-mac.file = ../../secrets/hk47.vader-mac.age;
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "daily";
  };

  services.fstrim.enable = true;
  services.openssh.enable = true;
  security.rtkit.enable = true;
  services.fwupd.enable = true;

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # Components required to complete the onboarding
      "zha"
      "met"
      "radio_browser"
      "homekit"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      "automation ui" = "!include automations.yaml";
    };
  };
  services.avahi = {
    enable = true;
    reflector = true;
    nssmdns = true;
    allowInterfaces = ["wlp2s0"];
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi7;
    openFirewall = true;
  };

  alexghr.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
    exitNode = true;
  };

  powerManagement.powertop.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    powertop
    lsof
    (wakeVader config.age.secrets.vader-mac.path)
  ];
}

