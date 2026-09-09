{
  pkgs,
  lib,
  ...
}: let
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

  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    enableDefaultConfig = false;
    includes = ["~/.ssh/config.local"];
    settings = {
      trip = {
        User = "root";
      };

      "*alexg-box" = {
        Tag = "alexg-box";
      };

      "Match tagged alexg-box" = lib.hm.dag.entryAfter ["*alexg-box"] {
        ProxyJump = "bastion";
        User = "alexg";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };

      alexg-box = {
        ForwardAgent = "yes";
        # setup gpg-agent forwarding in each host
      };

      # port forward
      pf-alexg-box = {
        LocalForward = [
          "8080 localhost:8080"
          "8000 localhost:8000"
          "3000 0.0.0.0:3000"
          "8545 localhost:8545"
        ];
      };

      # no forwarding rules. Useful when scp-ing files around to no disturb forwarded agents
      nf-alexg-box = {
        ForwardAgent = false;
        ForwardX11 = false;
        ClearAllForwardings = true;
      };
    };
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

  xdg.configFile = {
    "git/config".source = ../dotfiles/git/config;
    "tmux/tmux.conf".source = ../dotfiles/tmux/tmux.conf;
  };
}
