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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  boot = {
    kernelParams = ["cma-256M"];
    kernelPackages = pkgs.linuxPackages_6_1;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = false;
      raspberryPi = {
        enable = true;
        version = 4;
        #uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=256
        '';
      };
    };
    # custom /tmp in filesystems
    # I needed more storage in order for nix to be able to build things
    # default tmpOnTmpfs allocates 50% of RAM, which is 2GiB on this system
    tmpOnTmpfs = false;
  };

  time.timeZone = "Europe/London";

  nixpkgs.config.allowUnfree = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    useDHCP = false;
    hostName = "hk47";
    networkmanager.enable = false;
    wireless = {
      enable = false;
      interfaces = ["wlan0"];
    };

    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    firewall.enable = true;
    #firewall.allowedTCPPorts = [8443 21063 21604];
    #firewall.allowedUDPPorts = [5353];

    firewall.allowedTCPPorts = [
      8443 # unifi
      # open a bunch of ports home-assistant's homekit bridge
      21064
      # 40000
    ];
    firewall.allowedUDPPorts = [
      # open a bunch of ports home-assistant's homekit bridge
      5353
      #1900
      #44608
      #36389
      #1900
      #34183
      #57495
      #42717
    ];
  };

  age.secrets = {
    tailscale.file = ../../secrets/hk47.tailscale.age;
    vader-mac = {
      file = ../../secrets/hk47.vader-mac.age;
      owner = "ag";
      group = "users";
    };
  };

  users.mutableUsers = true;

  environment.systemPackages = with pkgs; [
    vim raspberrypi-eeprom
    libraspberrypi
    (wakeVader config.age.secrets.vader-mac.path)
  ];

  services.openssh.enable = true;
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
    allowInterfaces = ["eth0"];
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.nix_2_16;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
}

