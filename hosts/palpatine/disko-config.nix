{config, ...}: {
  disko.devices = {
    disk = let
      disk0 = "disk0";
      disk1 = "disk1";
    in {
      disk0 = {
        type = "disk";
        name = disk0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512MB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = ["umask=0077"];
              };
            };
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["--label ${disk0}"];
              };
            };
          };
        };
      };
      disk1 = {
        type = "disk";
        name = disk1;
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["--data raid1" "--metadata raid1" "--label ${disk1}" "/dev/disk/by-label/${disk0}"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "relatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    inherit mountOptions;
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/var" = {
                    mountpoint = "/var";
                    mountOptions = ["noatime"]; # disable compression
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
