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
              subvolumes =
                let
                  mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
                in
                {
                  "/root" = {
                    inherit mountOptions;
                    mountpoint = "/";
                  };
                  "/nix" = {
                    inherit mountOptions;
                    mountpoint = "/nix";
                  };
                  "/varlib" = {
                    inherit mountOptions;
                    mountpoint = "/var/lib";
                  };
                  "/swap" = {
                    mountOptions = [ "noatime" "nodatacow" ];
                    mountpoint = "/swap";
                  };
                };
            };
          }
        ];
      };
    };
  };
}
