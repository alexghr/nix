{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    fsType = "btrfs";
    options = ["subvol=persist" "compress=zstd" "noatime"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    fsType = "btrfs";
    options = ["subvol=log" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C797-CAEA";
    fsType = "vfat";
  };

  fileSystems."/tmp" = {
    fsType = "btrfs";
    device = "/dev/disk/by-uuid/708b4e6f-2d05-4047-ac9f-5278adecc766";
    options = ["subvol=tmptmp" "compress=zstd" "noatime"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/779091ff-584e-4bf4-8ee7-ee31668e83c3";}
  ];
}
