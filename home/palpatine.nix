{
  config,
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

  systemd.user.services.ssh-add-keys = {
    Unit = {
      Description = "Load YubiKey SSH key stubs";
      Requires = ["ssh-agent.service"];
      After = ["ssh-agent.service" "graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "5min";
      Environment = [
        "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}"
        "SSH_ASKPASS=${osConfig.programs.ssh.askPassword}"
        "SSH_ASKPASS_REQUIRE=force"
      ];
      # Load the PIN-protected key first, then prompt to decrypt the Git stub.
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519_sk %h/.ssh/git-signing";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

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
