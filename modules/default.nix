{...}: {
  imports = [
    ./checks.nix
    ./darwin-modules.nix
    ./btrfs.nix
    ./zram.nix
    ./nix.nix
    ./systemd-boot.nix
    ./system-tools.nix
    ./home-manager.nix
  ];
}
