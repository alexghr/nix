# nix run github:numtide/nixos-anywhere -- --flake .#b1 root@<ip>

{
 config,
 pkgs,
 lib,
 modulesPath,
 ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./nginx.nix
  ];

  system.stateVersion = "23.05";

  disko.devices = import ./disk-configuration.nix {
    inherit lib;
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "weekly";
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 2048;
  }];

  boot = {
    supportedFilesystems = [ "btrfs" ];

    loader.grub = {
      enable = true;
      forceInstall = true;
      device = "/dev/sda";
    };
  };

  networking = {
    hostName = "b1";
    firewall = {
      enable = true;
      allowedTCPPorts = [80];
    };
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  users = {
    groups.plausible = {};

    users = {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
      ];

      plausible = {
        group = "plausible";
        isSystemUser = true;
      };
    };
  };

  age.secrets = {
    plausible-keybase.file = ../../secrets/plausible.keybase.age;
    ghcr.file = ../../secrets/webby.ghcr.age;
    tailscale.file = ../../secrets/b1.tailscale.age;
  };

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        alexghr = {
          image = "ghcr.io/alexghr/www";
          login = {
            username = "alexghr";
            passwordFile = config.age.secrets.ghcr.path;
            registry = "ghcr.io";
          };
          ports = [
            "8001:80"
          ];
        };
        yaacc = {
          image = "ghcr.io/alexghr/yaacc";
          login = {
            username = "alexghr";
            passwordFile = config.age.secrets.ghcr.path;
            registry = "ghcr.io";
          };
          ports = [
            "8003:3000"
          ];
        };
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };

    # this comes with SSH jail by default
    fail2ban.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = false;
    };

    clickhouse = {
      enable = true;
    };

    plausible = {
      enable = true;
      # I've migrated old data in here
      database = {
        clickhouse.url = "http://127.0.0.1:8123/plausible";
        postgres.dbname = "plausible";
      };

      server = {
        disableRegistration = true;
        baseUrl = "https://plausible.alexghr.me";
        secretKeybaseFile = config.age.secrets.plausible-keybase.path;
        port = 8000;
      };
    };
  };

  alexghr.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
    exitNode = true;
  };
}
