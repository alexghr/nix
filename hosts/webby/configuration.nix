{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_6_1;
    supportedFilesystems = [ "btrfs" ];

    loader.grub = {
      enable = true;
      forceInstall = true;
      device = "/dev/sda";
    };
  };

  networking = {
    useDHCP = false;

    interfaces = {
      eth0.useDHCP = true;
    };

    firewall = {
      enable = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.nix_2_13;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # this comes with SSH jail by default
  services.fail2ban.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  #############################

  networking.hostName = "webby";
  networking.firewall.allowedTCPPorts = [80];

  age.secrets.webbyGhcrToken.file = ../../secrets/webby.ghcr.age;
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        alexghr = {
          image = "ghcr.io/alexghr/www";
          login = {
            username = "alexghr";
            passwordFile = config.age.secrets.webbyGhcrToken.path;
            registry = "ghcr.io";
          };
          ports = [
            "80:80"
          ];
        };
      };
    };
  };
}

