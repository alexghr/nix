{pkgs, ...}: {
  home.stateVersion = "21.11";
  xdg.enable = true;

  home.packages = with pkgs; [
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
