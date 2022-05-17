{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ag";
  home.homeDirectory = "/home/ag";
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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

  home.packages = with pkgs; [
    nodejs-16_x
    nodePackages.node2nix
    imagemagick
    ripgrep
    bat
    python3Full
    jq
    bc
  ];

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
        PS1="\[\033[01;32m\][\t]\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]$info\[\033[00m\]$ "
      }

      PROMPT_COMMAND=set_ps1
      set_ps1
    '';
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [vim-nix vim-colors-solarized];
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
}
