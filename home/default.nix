{pkgs, ...}: {
  home.stateVersion = "21.11";
  xdg.enable = true;

  home.packages = with pkgs; [
    git
    wget
    bat
    tree
    unzip
    zip
    fzf
    yazi
    btop
    tmux
    nix-index
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
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.configFile = {
    "git/config".source = ../dotfiles/git/config;
    "tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
  };
}
