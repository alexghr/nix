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
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
      fsType = "btrfs";
      options = [ "subvol=@" ] ++ commonMountOptions;
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
      fsType = "btrfs";
      options = [ "subvol=@home" ] ++ commonMountOptions;
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
      fsType = "btrfs";
      options = [ "subvol=@nix" ] ++ commonMountOptions;
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/D648-6016";
      fsType = "vfat";
    };

  fileSystems."/mnt/shares/public" = {
    device = "//trip.home/public";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    # add sec=none to browser as guest
    in ["${automount_opts},credentials=${config.age.secrets.ag-samba.path},uid=1000,gid=100"];
  };

  fileSystems."/mnt/shares/ag" = {
    device = "//trip.home/ag";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=${config.age.secrets.ag-samba.path},uid=1000,gid=100"];
  };

  swapDevices = [];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
