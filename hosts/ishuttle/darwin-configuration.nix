# add home-manager as a channel first
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # link home.packages to /Applications so that Spotlight can find them
  system.build.applications = pkgs.lib.mkForce (pkgs.buildEnv {
    name = "applications";
    paths = config.environment.systemPackages ++ config.home-manager.users.ag.home.packages;
    pathsToLink = "/Applications";
  });

  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    pinentry
    pinentry_mac
    gnupg
  ];
}
