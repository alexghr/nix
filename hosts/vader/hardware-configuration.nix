# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: let commonMountOptions = [
  "compress=zstd"
  "noatime"
  "ssd"
  "discard=async"
  "space_cache=v1"
]; in

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/nvme0n1p3";
      fsType = "btrfs";
      options = [ "subvol=@" ] ++ commonMountOptions;
    };

  fileSystems."/home" =
    { device = "/dev/nvme0n1p3";
      fsType = "btrfs";
      options = [ "subvol=@home" ] ++ commonMountOptions;
    };

  fileSystems."/nix" =
    { device = "/dev/nvme0n1p3";
      fsType = "btrfs";
      options = [ "subvol=@nix" ] ++ commonMountOptions;
    };

  fileSystems."/boot" =
    { device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };

  swapDevices = [];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
