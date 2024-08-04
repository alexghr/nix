{...}: {
  imports = [
    ./darwin-modules.nix
    ./btrfs.nix
    ./nix.nix
    ./systemd-boot.nix
    ./alacritty-theme.nix
  ];
}
