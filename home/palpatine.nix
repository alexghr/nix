{
  pkgs,
  lib,
  ...
}: {
  # Home Manager will not back up the old tmpfiles symlinks itself.
  home.activation.migrateTmpfiles = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    run ${pkgs.bash}/bin/bash ${../scripts/migrate-tmpfiles.sh} "$HOME"
  '';
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
