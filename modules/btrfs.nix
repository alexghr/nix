{...}: {
  flake.nixosModules.btrfs = {
    boot.supportedFilesystems = ["btrfs"];
    services.fstrim.enable = true;
    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
      interval = "daily";
    };
  };
}
