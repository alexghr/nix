{pkgs, ...}: let
  nr = pkgs.writeShellScriptBin "nr" ''
    set -euo pipefail
    program="''${1:?Usage: nr PACKAGE [ARGUMENTS...]}"
    shift
    exec nix run "github:nixos/nixpkgs/nixpkgs-unstable#$program" -- "$@"
  '';
in {
  home.stateVersion = "21.11";
  xdg.enable = true;

  home.packages = with pkgs; [
    nr
    git
    bat
    tree
    unzip
    zip
    fzf
    yazi
    btop
    tmux
    nix-index
    neovim-nightly
    imagemagick
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    FLAKE = "$HOME/code/alexghr/nix";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ../dotfiles/bash/bashrc;
  };

  xdg.configFile = {
    "git/config".source = ../dotfiles/git/config;
    "tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
  };
}
