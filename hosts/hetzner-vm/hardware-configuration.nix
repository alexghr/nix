{ config, lib, pkgs, modulesPath, ... }:

let
  commonMountOptions = [
    "compress=zstd"
    "noatime"
    "ssd"
  ];
in
  {
    imports =
      [ (modulesPath + "/profiles/qemu-guest.nix")
      ];

    boot.supportedFilesystems = ["btrfs"];
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        options = [ "subvol=root" ] ++ commonMountOptions;
      };

    fileSystems."/home" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        options = [ "subvol=home" ] ++ commonMountOptions;
      };

    fileSystems."/etc/nixos" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        options = [ "subvol=nixos" ] ++ commonMountOptions;
      };

    fileSystems."/nix" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        options = [ "subvol=nix" ] ++ commonMountOptions;
      };

    fileSystems."/var/log" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        neededForBoot = true;
        options = [ "subvol=log" ] ++ commonMountOptions;
      };

    fileSystems."/boot" =
      { device = "/dev/sda1";
        fsType = "btrfs";
        neededForBoot = true;
        options = [ "subvol=boot" ] ++ commonMountOptions;
      };

    swapDevices = [ ];
  }
