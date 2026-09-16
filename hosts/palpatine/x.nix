{
  lib,
  pkgs,
  ...
}: {
  services.xserver = {
    enable = true;
    excludePackages = [pkgs.xterm];
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
        xss-lock
        xclip

        dunst # notification manager
        maim # screenshot tool
        dex # autostart

        rofi # program launcher
        rofi-calc

        qimgv # image viewer
        llpp # pdf viewer
        pcmanfm # file manager

        pavucontrol

        kdePackages.kwallet
        kdePackages.kwalletmanager
      ];
    };
  };

  # Restore the display if the monitor reconnects after NVIDIA resumes with no output.
  services.autorandr = {
    enable = true;
    profiles.workstation = {
      fingerprint.DP-0 = "00ffffffffffff0010ac7fa14c4f3430031f0104b55825783b2141af4f46aa260e5054210800010101010101010101010101010101013c9b00a0f040386030203500706f3100001a000000ff0023484c41594d78677741424c43000000fd000190f6f663010a202020202020000000fc0044656c6c2041573338323144570283020320f12309070183010000654b04000101e305c000e2006ae606050178601f31dd00a0f040426030203500706f3100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070137903000f000aa4140e0e07012045000002010d31f17a4f5f54aa65020e01455403013c933d0104ff0e9f002f801f003f065d0002000400a4810104ff0e9f002f801f003f067100020004001b060104ff0e9f002f801f003f064d00020004000000000000000000000000000000000000000000000000000000000000e190";
      config = {
        DP-0 = {
          enable = true;
          primary = true;
          mode = "3840x1600";
          rate = "144.00";
          position = "0x0";
        };
        HDMI-0.enable = false;
        HDMI-1.enable = false;
        DP-1.enable = false;
        DP-2.enable = false;
        DP-3.enable = false;
      };
    };
  };

  # NVIDIA can report disconnect and reconnect within a second on resume.
  # Let both hotplug events run autorandr instead of rate-limiting the reconnect.
  systemd.services.autorandr.startLimitIntervalSec = lib.mkForce 0;

  programs.i3lock.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  services.dbus.packages = [pkgs.kdePackages.kwallet];

  security.pam.services.kwallet.kwallet = {
    enable = true;
    forceRun = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig.enable = true;
  };
}
