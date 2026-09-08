{
  pkgs,
  darwinModules,
  ...
}: {
  imports = [darwinModules.nix darwinModules.system-tools darwinModules.home-manager];

  networking.hostName = "mackey";
  system.primaryUser = "ag";
  system.stateVersion = 4;
  nix.settings.trusted-users = ["ag"];

  users.users.ag = {
    home = "/Users/ag";
    shell = pkgs.bashInteractive;
  };
  environment.shells = [pkgs.bashInteractive];
  programs.bash.completion.enable = true;
  programs.zsh.enable = true;
  fonts.packages = [pkgs.monaspace];
  environment.systemPackages = [pkgs.pinentry_mac];
  home-manager.users.ag.imports = [../../home/mackey.nix];
}
