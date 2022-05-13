# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let oldNixpkgs = import (builtins.fetchGit {
  # Descriptive name to make the store path easier to identify
  name = "old-nixpkgs";
  url = "https://github.com/nixos/nixpkgs/";
  # Commit hash for nixos-unstable as of 2018-09-12
  # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  ref = "refs/heads/master";
  rev = "84cf00f98031e93f389f1eb93c4a7374a33cc0a9";
}) {}; in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  time.timeZone = "Europe/London";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

     #kernelPackages = pkgs.linuxPackages_latest;
     # hoping Kernel 5.10 will resolve my random reboots (Ryzen issue)
     kernelPackages = pkgs.linuxPackages_5_10;
     supportedFilesystems = [ "btrfs" ];
  };

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "nixtrooper";
    wireless.enable = false;

    useDHCP = false;
    interfaces.enp5s0.useDHCP = true;

    firewall.enable = true;
    firewall.allowedTCPPorts = [
      3000 # default Next.js development port
      6000 # default Firefox debug server
    ];
  };

  services.fstrim.enable = true;

  services.openssh.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
  };

  nix = {
    package = pkgs.nix_2_7;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    pciutils
    usbutils
    tree
    gnome3.adwaita-icon-theme
    pinentry-gnome
    pinentry
    pinentry-curses
    ntfs3g
    automake
    #autoconf
    oldNixpkgs.autoconf
    gcc
    libjpeg
    mozjpeg

    dnsutils
    lm_sensors
    mprime

    android-tools
  ];

  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  programs.dconf.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
    # enableSSHSupport = true;
  };

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
      nvidiaSettings = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
    screenSection = ''
      Option "metamodes" "3840x1600_144 +0+0 {AllowGSYNCCompatible=On}"
    '';
    #displayManager.sddm.enable = true;
    #desktopManager.plasma5.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.ag = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video"  ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.ag = { pkgs, ... }: {
    # https://matthewrhone.dev/nixos-npm-globally
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
      open = "xdg-open";

      # Typos!
      gti = "git";
      gt = "git";
      gi = "git";
    };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh

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

    home.packages = let patchedObs = pkgs.obs-studio.override { ffmpeg = pkgs.ffmpeg-full; }; in with pkgs; [
      nodejs-16_x
      nodePackages.node2nix
      jq
      xclip
      imagemagick
      bc

      vscode
      slack
      firefox
      filezilla
      bitwarden
      kitty
      tdesktop # telegram
      #whatsapp-for-linux
      gimp-with-plugins
      libreoffice

      gnomeExtensions.dash-to-dock
      gnomeExtensions.brightness-control-using-ddcutil #gnome-ddc-brightness-control
      gnomeExtensions.hue-lights
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.nordvpn-connect
      gnome.gnome-tweak-tool

      desktop-file-utils
      #obs-studio
      wineFull
      cabextract # needed to patch AoE4
      steam
      nv-codec-headers
      ffmpeg-full
      patchedObs

      ripgrep
      python3Full

      v4l-utils

      vlc
      chromium

      inkscape
      discord
      libguestfs

      unzip
      ngrok

      google-chrome
      gnumake
    ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}

