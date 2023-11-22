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
            name = "boot";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = [ "bios_grub" ];
          }
          {
            name = "root";
            start = "1M";
            end = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/nix";
                };
                "/swap" = {
                  mountOptions = [ "noatime" "nodatacow" ];
                  mountpoint = "/swap";
                };
                "/varlib" = {
                  mountpoint = "/var/lib";
                };
                "/atticd" = {
                  mountpoint = "/var/lib/atticd/storage";
                };
              };
            };
          }
        ];
      };
    };
  };
}
