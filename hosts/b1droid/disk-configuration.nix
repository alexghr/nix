{ disks ? [ "/dev/sda" ], ... }:
{
  disk = {
    main = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "0";
            end = "512M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            start = "512M";
            end = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/swap" = {
                  mountOptions = [ "noatime" "nodatacow" ];
                };
                "/varlib" = {
                  mountpoint = "/var/lib";
                };
              };
            };
          }
        ];
      };
    };
  };
}
