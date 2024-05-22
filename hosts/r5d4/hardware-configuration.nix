# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: let commonMountOptions = [
  "compress=zstd"
  "noatime"
  "autodefrag"
]; in

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=root" ] ++ commonMountOptions;
    };

  fileSystems."/home" =
    { device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=home" ] ++ commonMountOptions;
    };

  fileSystems."/nix" =
    { device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=nix" ] ++ commonMountOptions;
    };

  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "vfat";
      # https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/14?u=alexghr
      options= [ "umask=0077" "defaults" ];
    };

  swapDevices = [];
}