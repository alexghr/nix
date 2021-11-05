{ config, pkgs, lib, ... }:
{
	imports = [
		# requires
		# nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
		# before running install
		<nixos-hardware/raspberry-pi/4>
	];

	boot = {
		loader = {
			grub.enable = false;
			generic-extlinux-compatible.enable = true;
			#raspberryPi = {
			#	enable = true;
			#	version = 4;
			#};
		};

		# custom /tmp in filesystems
		# I needed more storage in order for nix to be able to build things
		# default tmpOnTmpfs allocates 50% of RAM, which is 2GiB on this system
		tmpOnTmpfs = false;
	};

	hardware = {
		enableRedistributableFirmware = true;
		raspberry-pi."4".fkms-3d.enable = true;
	};

	nixpkgs.config.allowUnfree = true;
	powerManagement.cpuFreqGovernor = "ondemand";

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/NIXOS_SD";
			fsType = "ext4";
			options = ["noatime"];
		};
		"/tmp" = {
			fsType = "tmpfs";
			device = "tmpfs";
			options = ["nosuid" "nodev" "noatime" "size=8G"];
		};
	};

	swapDevices = [
		{
			device = "/var/swap";
			size = 1024;
		}
	];

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

