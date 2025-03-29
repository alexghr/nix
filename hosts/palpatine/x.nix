{
  pkgs,
  config,
  ...
}: {
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.options = "compose:menu";
    videoDrivers = ["nvidia"];
    screenSection = ''
      Option "metamodes" "3840x1600_144 +0+0 {ForceCompositionPipeline=Off, ForceFullCompositionPipeline=Off, AllowGSYNCCompatible=On}"
    '';
    updateDbusEnvironment = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
        xss-lock
        xclip

        dunst # notification manager
        maim # screenshot tool
        dex # autostart

        rofi # program launcher
        rofi-calc

        qimgv # image viewer
        llpp # pdf viewer
        pcmanfm # file pkgs.alacritty-theme.monokai_promanager

        pavucontrol

        kdePackages.kwallet
        kdePackages.kwalletmanager
      ];
    };

    desktopManager.xterm.enable = true;
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  services.dbus.packages = [pkgs.kdePackages.kwallet];

  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

  programs.gnupg.agent = {
    enable = true;
    settings = {
      max-cache-ttl = 604800;
      default-cache-ttl = 604800;
    };
    enableExtraSocket = true;
    enableBrowserSocket = false;
    pinentryPackage =
      pkgs.kwalletcli.overrideAttrs
      (finalAttrs: previousAttrs: {
        meta.mainProgram = "pinentry-kwallet";
      });
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig.enable = true;
  };
}
