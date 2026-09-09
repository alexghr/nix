{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    lua-language-server
    ghostty
    bitwarden-desktop
    firefox
    thunderbird
    slack
    telegram-desktop
    gimp-with-plugins
    inkscape
    vlc
  ];

  programs.ssh.settings.alexg-box.RemoteForward = "/run/user/30038/gnupg/S.gpg-agent.fwd /run/user/1000/gnupg/S.gpg-agent.extra";

  xdg.configFile = {
    "i3/config".source = ../dotfiles/i3/config;
    "i3status/config".source = ../dotfiles/i3status/config;
  };
}
