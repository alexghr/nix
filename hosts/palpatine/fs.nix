{config, ...}: let
  commonMountOptions = [
    "compress=zstd"
    "noatime"
    "autodefrag"
  ];
  #sambaOptions = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${config.age.secrets.samba.path},uid=1000,gid=100";
in {
  #age.secrets.samba.file = ./secrets/samba.age;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
    fsType = "btrfs";
    options = ["subvol=@"] ++ commonMountOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
    fsType = "btrfs";
    options = ["subvol=@home"] ++ commonMountOptions;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/acd0e5ad-79da-4cc1-aaaa-f5941e495511";
    fsType = "btrfs";
    options = ["subvol=@nix"] ++ commonMountOptions;
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/D648-6016";
    fsType = "vfat";
  };

  #fileSystems."/mnt/shares/public" = {
  #  device = "//trip.home/public";
  #  fsType = "cifs";
  #  options = [sambaOptions];
  #};

  #fileSystems."/mnt/shares/ag" = {
  #  device = "//trip.home/ag";
  #  fsType = "cifs";
  #  options = [sambaOptions];
  #};
}
