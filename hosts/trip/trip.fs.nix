{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/78bf0dd5-4fe6-4081-81f6-c7ac21a9ace2";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime" "autodefrag"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D6C6-2997";
    fsType = "vfat";
    # https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/14?u=alexghr
    options = ["umask=0077" "defaults"];
  };

  fileSystems."/mnt/shares" = {
    device = "/dev/disk/by-uuid/6bfd2d5e-dea3-4c55-a61e-b9ddacc8ffe5";
    fsType = "bcachefs";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/6ABED17EBED1436D";
    fsType = "ntfs";
  };

  swapDevices = [];
}
