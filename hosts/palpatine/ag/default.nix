{
  pkgs,
  alexghrKeys,
  nixosModules,
  ...
}: {
  imports = [
    nixosModules.home-manager
    ./containers.nix
    ./steam.nix
  ];

  users.users.ag = {
    home = "/home/ag";
    isNormalUser = true;
    extraGroups = ["wheel" "pipewire" "audio" "video" "docker" "dialout" "uinput" "input"];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = alexghrKeys;
  };
  home-manager.users.ag = {
    imports = [../../../home/palpatine.nix];
    home.packages = [(pkgs.callPackage ./bin/i3_window.nix {})];
  };

  # Needed for bitwarden-desktop in the pinned unstable package set.
  nixpkgs.config.permittedInsecurePackages = ["electron-39.8.10"];
  fonts.packages = [pkgs.monaspace];
  fonts.fontconfig.defaultFonts.monospace = ["Monaspace Neon" "DejaVu Sans Mono"];
  programs.bash.completion.enable = true;
}
