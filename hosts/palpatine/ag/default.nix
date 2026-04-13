{
  config,
  packages,
  pkgs,
  alexghrKeys,
  nixosModules,
  lib,
  inputs,
  ...
}: let
  user = "ag";
  home = "/home/${user}";
  system = pkgs.stdenv.hostPlatform.system;
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = pkgs.config.allowUnfree or false;
      # Needed for bitwarden-desktop until nixpkgs moves it off Electron 39.
      permittedInsecurePackages = (pkgs.config.permittedInsecurePackages or []) ++ [
        "electron-39.8.10"
      ];
    };
  };
  neovimPkg = inputs.neovim-nightly.packages.${system}.default; #pkgs.neovim-nightly.neovim;
in {
  imports = [
    nixosModules.alacritty-theme
    ./containers.nix
    ./steam.nix
  ];

  users.users.${user} = {
    inherit home;
    isNormalUser = true;
    extraGroups = ["wheel" "pipewire" "audio" "video" "docker" "dialout" "uinput" "input"];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = alexghrKeys;
    packages = with unstable; [
      yazi
      btop
      neovimPkg
      lua-language-server
      nix-index

      alacritty
      ghostty
      bitwarden-desktop
      # vscode

      firefox
      brave
      thunderbird
      # libreoffice

      slack
      telegram-desktop

      gimp-with-plugins
      inkscape
      vlc

      file
      unzip
      imagemagick

      devenv

      (pkgs.callPackage ./bin/i3_window.nix {})
    ];
  };

  fonts.packages = [pkgs.monaspace];
  fonts.fontconfig.defaultFonts.monospace = [
    "Monaspace Neon"
    "DejaVu Sans Mono"
  ];

  environment.sessionVariables = {
    EDITOR = "${neovimPkg}/bin/nvim";
    #VISUAL = "${neovidePkg}/bin/neovide";
    FLAKE = "${home}/code/alexghr/nix";
  };

  programs.bash = {
    enableCompletion = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -laF";
      gti = "git";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-direct";
    escapeTime = 50;
    baseIndex = 1;
    shortcut = "s";
    keyMode = "vi";
    historyLimit = 10000;
    extraConfig = "";
    plugins = [
      pkgs.tmuxPlugins.sensible
    ];
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      push.default = "current";
      rerere.enabled = true;
    };
  };

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.plugins = with pkgs.vimPlugins; {
        start = [oil-nvim nvim-lspconfig];
      };
    };
  };

  systemd.user.tmpfiles.users.${user}.rules = let
    links = [
      ["${home}/.bashrc" ./config/bashrc]
      ["${home}/.config/alacritty/alacritty.toml" ./config/alacritty.toml]
      ["${home}/.config/alacritty/theme.toml" pkgs.alacritty-theme.monokai_pro]
      ["${home}/.config/i3/config" ./config/i3]
      ["${home}/.config/i3status/config" ./config/i3status]
      ["${home}/.config/git/config" ./config/gitconfig]
      ["${home}/.config/tmux/tmux.conf" ./config/tmux.conf]
      ["${home}/.config/zellij/config.kdl" ./config/zellij-config.kdl]
    ];
  in
    lib.map (link: "L+ ${lib.elemAt link 0} - - - - ${lib.elemAt link 1}") links;
}
