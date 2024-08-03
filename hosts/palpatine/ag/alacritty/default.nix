{
  pkgs,
  nixosModules,
  ...
}: {
  imports = [nixosModules.alacritty-theme];
  environment.systemPackages = [pkgs.unstable.alacritty];
  systemd.tmpfiles.rules = [
    "L+ /home/ag/.config/alacritty/alacritty.toml - - - - ${./alacritty.toml}"
    "L+ /home/ag/.config/alacritty/theme.toml - - - - ${pkgs.alacritty-theme.monokai_pro}"
  ];
}
