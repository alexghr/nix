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
  xdg.configFile = {
    "i3/config".source = ../dotfiles/i3/config;
    "i3status/config".source = ../dotfiles/i3status/config;
  };
}
