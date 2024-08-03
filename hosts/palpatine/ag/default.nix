{
  config,
  pkgs,
  alexghrKeys,
  nixosModules,
  lib,
  ...
}: let
  user = "ag";
  home = "/home/${user}";
  neovimPkg = pkgs.unstable.neovim;
  neovidePkg = pkgs.unstable.neovide;
in {
  imports = [
    nixosModules.alacritty-theme
    ./containers.nix
    ./steam.nix
  ];

  users.users.${user} = {
    inherit home;
    isNormalUser = true;
    extraGroups = ["wheel" "pipewire" "audio" "video" "docker"];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = alexghrKeys;
    packages = with pkgs.unstable; [
      yazi
      btop
      neovimPkg
      neovidePkg

      alacritty
      bitwarden
      vscode

      firefox
      google-chrome
      thunderbird
      libreoffice

      slack
      tdesktop

      gimp-with-plugins
      inkscape
      vlc

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
    VISUAL = "${neovidePkg}/bin/neovide";
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

  programs.starship = {
    enable = true;
    presets = ["pure-preset"];
    settings = {
      add_newline = false;
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

  systemd.user.tmpfiles.users.${user}.rules = let
    links = [
      ["${home}/.bashrc" ./config/bashrc]
      ["${home}/.config/alacritty/alacritty.toml" ./config/alacritty.toml]
      ["${home}/.config/alacritty/theme.toml" pkgs.alacritty-theme.monokai_pro]
      ["${home}/.config/i3/config" ./config/i3]
      ["${home}/.config/i3status/config" ./config/i3status]
      ["${home}/.config/git/config" ./config/gitconfig]
      ["${home}/.config/tmux/tmux.conf" ./config/tmux.conf]
    ];
    group = config.users.users.${user}.group;
  in
    lib.map (link: "L+ ${lib.elemAt link 0} - ${user} ${group} - ${lib.elemAt link 1}") links;
}
