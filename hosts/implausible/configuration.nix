{
  config,
  pkgs,
  ...
}:
{
  # Configuration inherited from hetzner-vm with 23.05 modifications
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
      allowedTCPPorts = [80];
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

  ##################################
  # machine configuration

  networking = {
    hostName = "implausible";
  };

  # so that I'm able to connect to Postgres
  users.users.plausible = {
    group = "plausible";
    isSystemUser = true;
  };

  age.secrets.plausible-release-cookie.file = ../../secrets/plausible.releaseCookie.age;
  age.secrets.plausible-admin-password.file = ../../secrets/plausible.admin.password.age;
  age.secrets.plausible-keybase.file = ../../secrets/plausible.keybase.age;

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = false;
    };

    plausible = {
      enable = true;
      releaseCookiePath = config.age.secrets.plausible-release-cookie.path;
      adminUser = {
        email = "alexghr@users.noreply.github.com";
        passwordFile = config.age.secrets.plausible-admin-password.path;
      };

      # I've migrated old data in here
      database = {
        clickhouse.url = "http://localhost:8123/plausible";
      };

      server = {
        disableRegistration = true;
        baseUrl = "https://plausible.alexghr.me";
        secretKeybaseFile = config.age.secrets.plausible-keybase.path;
        port = 8000;
      };
    };

    nginx = {
      enable = true;
      virtualHosts = {
        "plausible.alexghr.me" = {
          locations."/" = {
            proxyPass = "http://localhost:8000";
          };
        };
      };
    };
  };
}
