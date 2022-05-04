{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    kernelParams = ["cma-256M"];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi = {
        enable = true;
        version = 4;
        uboot.enable = true;
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
		hostName = "hk47";
		networkmanager.enable = false;
		wireless = {
			enable = true;
			interfaces = ["wlan0"];
		};
	};

	users = {
		mutableUsers = true;
		users.ag = {
			# don't forget to set a password
			isNormalUser = true;
			extraGroups = ["wheel"];
		};
	};

	programs.sway = {
		enable = true;
		wrapperFeatures.gtk = true;
		extraPackages = with pkgs; [
			swaylock
			swayidle
			wl-clipboard
			alacritty
			dmenu
		];
	};

	environment.systemPackages = with pkgs; [vim raspberrypi-eeprom];
	services.openssh.enable = true;
}

