{
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
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
              };
            };
          };
        };
      };
      disk1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["--force" "--data raid1" "--metadata raid1" "/dev/disk/by-partlabel/disk-disk0-data"];
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
