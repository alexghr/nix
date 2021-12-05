# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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

     kernelPackages = pkgs.linuxPackages_latest;
     supportedFilesystems = [ "btrfs" ];
  };

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "nixtrooper";
    wireless.enable = false;

    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
    interfaces.enp5s0.useDHCP = true;

    firewall.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    pciutils
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.ag = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.ag = { pkgs, ... }: {
    programs.bash.enable = true;
    home.packages = with pkgs; [
      nodejs-16_x
      nodePackages.node2nix
      vscode
      slack
  
      firefox
      filezilla
      bitwarden
    ];
  };
}

