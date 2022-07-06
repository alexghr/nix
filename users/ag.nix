{ config, pkgs, ... }:
let
  githubSshKeys = import ../lib/github-ssh-keys.nix { inherit pkgs; };
  username = "ag";
  packages = with pkgs; [
    nodejs-16_x
    imagemagick
    kubectl
    kubeseal
  ] ++ (if pkgs.stdenv.isLinux then [
    v4l-utils
    libguestfs
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

    vscode
    xclip

    desktop-file-utils
    vlc
    filezilla
    libreoffice
    bitwarden

    obs-studio
    winePackages.full
    ffmpeg-full
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
      ++ (if config.virtualisation.podman.enable then ["podman"] else []);

    openssh.authorizedKeys.keys = githubSshKeys {
      username = "alexghr";
      sha256 = "sha256-JfAZgyo8CNBmik7qW93OP2yjnRa4XS81hx4kr+wfTTM=";
    };
  } else {});

  home-manager.users."${username}" = {

    home.username = username;
    home.homeDirectory = config.users.users."${username}".home;
    home.stateVersion = "21.11";

    home.packages = packages ++ (if enableGuiPackages then guiPackages else []);

    home.sessionVariables = {
      NPM_PREFIX = "~/.npm-packages";
      PATH = "$PATH:$NPM_PREFIX/bin";
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
      settings = {
        window = {
          padding = { x = 4; y = 8; };
          decorations = "full";
          opacity = 1;
          startup_mode = "Windowed";
          title = "Alacritty";
          dynamic_title = true;
          gtk_theme_variant = "None"; # pick the system's default
        };

        font = let victorMono = style: {
          family = "Victor Mono";
          inherit style;
        }; in {
          size = 12;
          use_thin_strokes = true;
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
  };
}

