# add home-manager as a channel first
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      trusted-users = ag
    '';
  };

  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    pinentry_mac
    gnupg
  ];

  environment.shells = [pkgs.bashInteractive];

  home-manager.users.ag.programs.bash.bashrcExtra = pkgs.lib.mkAfter ''
    export PATH="/etc/profiles/per-user/$USER/bin:/Users/$USER/.npm/bin:$PATH"
  '';

  age.secrets.ag-npmrc = {
    file = ../../secrets/ag.npmrc.age;
    owner = "ag";
    group = "staff";
  };
}
