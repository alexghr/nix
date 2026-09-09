{pkgs, ...}: {
  programs.steam = {
    enable = true;
    package = pkgs.unstable.steam;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-ng
    lutris
    bottles
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS = "$HOME/.steam/root/compatibilitytools.d";
  };
}
