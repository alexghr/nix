# add home-manager as a channel first
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nix-darwin>
  ];

  # link home.packages to /Applications so that Spotlight can find them
  system.build.applications = pkgs.lib.mkForce (pkgs.buildEnv {
    name = "applications";
    paths = config.environment.systemPackages ++ config.home-manager.users.ag.home.packages;
    pathsToLink = "/Applications";
  });

  users.users.ag = {
    name = "ag";
    home = "/Users/ag";
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.ag = { pkgs, ... }: {
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      '';
    };

    home.packages = with pkgs; [
      vim
      #kitty
      alacritty
    ];
  };

  environment.systemPackages = [
    pkgs.vim
  ];
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
