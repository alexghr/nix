{
  pkgs,
  ...
}: {
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

  # mount multi-device bcachefs
  # https://discourse.nixos.org/t/how-do-i-mount-multiple-bcachefs-devices-on-boot/37463/10
  # https://github.com/NixOS/nixpkgs/issues/72970
  # https://github.com/systemd/systemd/issues/8234
  systemd.services.mount-bcache = {
    description = "mount bcache";
    script = ''
      mount_flags="noatime"
      mount_devices="/dev/sda1:/dev/sdb1"
      mount_point="/mnt/bcache"

      # disk already mounted, remount with new flags
      # assumes that the mount point and device are the same
      if ${pkgs.util-linux}/bin/mountpoint -q "$mount_point"; then
        mount_flags="$mount_flags,remount"
        mount_devices=""
      fi

      ${pkgs.util-linux}/bin/mount -o $mount_flags -t bcachefs $mount_devices $mount_point
    '';
    # samba shares live on this disk
    wantedBy = [ "multi-user.target" "samba.target" ];
  };

  swapDevices = [];
}
