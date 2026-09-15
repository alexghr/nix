{
  pkgs,
  osConfig,
  ...
}: {
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
    calibre
  ];

  systemd.user.services.ssh-agent.Service.Environment = [
    "SSH_ASKPASS=${osConfig.programs.ssh.askPassword}"
  ];

  services.gpg-agent = {
    enableExtraSocket = true;
    pinentry.package = pkgs.pinentry-all;
    defaultCacheTtl = 600;
    maxCacheTtl = 3600;
  };

  xdg.configFile = {
    "i3/config".source = ../dotfiles/i3/config;
    "i3status/config".source = ../dotfiles/i3status/config;
  };
}
