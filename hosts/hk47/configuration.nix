{ config, pkgs, lib, ... }:
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
    firewall.allowedTCPPorts = [8443];
  };

  users.mutableUsers = true;

  environment.systemPackages = with pkgs; [vim raspberrypi-eeprom libraspberrypi];

  services.openssh.enable = true;

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi7;
    openFirewall = true;
  };
}

