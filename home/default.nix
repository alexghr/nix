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
    agenix
    agents.codex
    agents.pi
    yubikey-manager
    nr
    git
    openssh
    bat
    tree
    unzip
    zip
    fzf
    yazi
    btop
    tmux
    nix-index
    unstable.neovim
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

  services.ssh-agent = {
    enable = true;
    package = pkgs.openssh;
    socket = "ssh-agent";
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    noAllowExternalCache = false;
  };

  home.file.".ssh/config".source = ../dotfiles/ssh/config;
  home.file.".ssh/git-signing.pub".text = (import ../alexghr.keys.nix).gitSigning + "\n";

  xdg.configFile = {
    "git/config".source = ../dotfiles/git/config;
    "tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
  };
}
