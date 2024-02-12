{...}: let
  commonMountOptions = [
  ];
  subvol = name: [
    "subvol=${name}"
    "compress=zstd"
    "noatime"
    "autodefrag"
  ];
in {
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = subvol "root";
  };

  fileSystems."/home" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = subvol "home";
  };

  fileSystems."/nix" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = subvol "nix";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
    # https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/14?u=alexghr
    options = ["umask=0077" "defaults"];
  };

  swapDevices = [];
}
