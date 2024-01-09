{ config, pkgs, ... }:
let
  username = "ag";
  packages = with pkgs; [
    imagemagick
    kubectl
    kubeseal
  ] ++ (if pkgs.stdenv.isLinux then [
    v4l-utils
    libguestfs
  ] else [])
  ++ (if pkgs.config.allowUnfree then [
    ngrok
  ] else []);

  enableGuiPackages = pkgs.stdenv.isDarwin || config.services.xserver.enable;
  guiPackages = if pkgs.stdenv.isLinux then with pkgs; [
    firefox
    chromium
    google-chrome

    gimp-with-plugins
    inkscape

    discord
    slack
    tdesktop

    xclip

    desktop-file-utils
    vlc
    filezilla
    libreoffice
    bitwarden

    obs-studio
    winePackages.full
    ffmpeg-full

    unstable.thunderbird
  ] else [];

  vimPlugins = with pkgs.vimPlugins; [
    vim-nix
    vim-colors-solarized
  ];

in {
  users.users."${username}" = {
    home = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  } // (if pkgs.stdenv.isLinux then {
    isNormalUser = true;

    extraGroups = ["wheel"]
      ++ (if config.services.pipewire.enable then ["pipewire" "audio" "video"] else [])
      ++ (if config.virtualisation.podman.enable then ["podman"] else [])
      ++ (if config.virtualisation.lxd.enable then ["lxd"] else []);

    # get these from https://github.com/alexghr.keys
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELd6/RHyZ3Rw6251R+nWGvkPseaX2yAC2DlZAtRziIt"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
    ];
  } else {});

  home-manager.users."${username}" = hm: {

    home.username = username;
    home.homeDirectory = config.users.users."${username}".home;
    home.stateVersion = "21.11";

    home.packages = packages ++ (if enableGuiPackages then guiPackages else []);

    home.sessionVariables = {
      NPM_PREFIX = "$HOME/.npm-packages";
      PATH = "$PATH:$NPM_PREFIX/bin:$HOME/.corepack";
      EDITOR = "vim";
    };

    home.shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -laF";
      grep = "grep --color=auto";

      tmux = "tmux -2u";

      df = "df -x squashfs";

      # Typos!
      gti = "git";
      gt = "git";
      gi = "git";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.git = {
      enable = true;
      userName = "Alex Gherghisan";
      userEmail = null; # intentionally left blank
      signing = null; # intentionally left blank

      aliases = {
        st = "status --short --branch";
        ax = "add --update";
        ct = "commit";
        cta = "commit --amend";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --branches --remotes --tags";
        ck = "checkout";
        get = "fetch --all --prune";
        rb  = "rebase";
        rbi = "rebase --interactive";
        rbc = "rebase --continue";
        rba = "rebase --abort";
        aa = "add --all";
        staged = "diff --cached";
        pushf = "push --force-with-lease";
        sha = "rev-parse HEAD";
        mu = "merge --ff-only @{u}";
        ru = "rebase --interactive @{u}";
      };

      extraConfig = {
        init.defaultBranch = "main";
        push.default = "current";
        rerere.enabled = true;
        commit.gpgsign = true;
        safe.directory = "/etc/nixos";
      };
    };

    programs.tmux = {
      enable = true;
      terminal = "screen-256color";
      shell = "$SHELL";
      prefix = "C-s";
      escapeTime = 100;
      baseIndex = 1;

      extraConfig = ''
        set -g mouse on

        set -g set-titles on
        set -g set-titles-string "#T"

        set -g status-bg black
        set -g status-fg white
        set -g status-left ""
        set -g status-right "#[fg=green]#H"
        set-window-option -g window-status-current-style bg=red

        set -g history-limit 10000

        # Windows
        bind-key -n F1 select-window -t 1
        bind-key -n F2 select-window -t 2
        bind-key -n F3 select-window -t 3
        bind-key -n F4 select-window -t 4
        bind-key -n F5 select-window -t 5
        bind-key -n F6 select-window -t 6
        bind-key -n F7 select-window -t 7
        bind-key -n F8 select-window -t 8

        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-5 select-window -t 5
        bind-key -n M-6 select-window -t 6
        bind-key -n M-7 select-window -t 7
        bind-key -n M-8 select-window -t 8

        bind C-s select-pane -t :.+
        bind , command-prompt 'rename-window %%'

        bind y run-shell "tmux save-buffer - | xclip -sel clip"

        bind '%' split-window -h -c '#{pane_current_path}'  # Split panes horizontal
        bind '"' split-window -v -c '#{pane_current_path}'  # Split panes vertically
        bind c new-window -c '#{pane_current_path}' # Create new window
      '';
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        source /etc/profiles/per-user/ag/etc/profile.d/hm-session-vars.sh

        function set_ps1() {
          info=""
          if [ -n "$IN_NIX_SHELL" ]; then
            info="$info \[\e[97m\](\[\e[96m\]nix\[\e[97m\])\[\e[39m\]"
          fi

          git_branch=$(git branch --show-current 2> /dev/null)
          if [ $? == 0 ]; then
            info="$info \[\e[97m\](\[\e[96m\]$git_branch\[\e[97m\])\[\e[39m\]"
          fi
          PS1="\[\033[01;32m\][\t]\[\033[00m\]\[\033[01;35m\]\\u@\\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$info\[\033[00m\]$ "
        }

        PROMPT_COMMAND=set_ps1
        set_ps1
      '';
    };

    programs.vim = {
      enable = true;
      plugins = vimPlugins;
      settings = {
        background = "dark";
        number = true;
      };
      extraConfig = ''
        syntax enable
        let g:solarized_termcolors=256
        colorscheme solarized
      '';
    };

    programs.alacritty = {
      enable = enableGuiPackages;
      package = pkgs.unstable.alacritty;
      settings = {
        window = {
          padding = { x = 4; y = 8; };
          decorations = "full";
          opacity = 1;
          startup_mode = "Windowed";
          title = "Alacritty";
          dynamic_title = true;
          gtk_theme_variant = "None"; # pick the system's default
          option_as_alt = "Both";
        };

        import = [
          pkgs.alacritty-theme.zenburn
        ];

        font = let victorMono = style: {
          family = "Victor Mono";
          inherit style;
        }; in {
          size = 12;
          normal = victorMono "Regular";
          bold = victorMono "Bold";
          italic = victorMono "Italic";
          bold_italic = victorMono "Bold Italic";
        };

        cursor = {
          style = "Block";
        };

        live_config_reload = true;
      };
    };

    programs.i3status = if pkgs.stdenv.isLinux && config.services.xserver.enable && config.services.xserver.windowManager.i3.enable then {
      enable = true;
      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };
    } else {};

    services.gpg-agent = {
      maxCacheTtl = 604800;
      defaultCacheTtl = 604800;
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.vscode.enable = enableGuiPackages;
    programs.vscode.package = pkgs.unstable.vscode;
  };
}

