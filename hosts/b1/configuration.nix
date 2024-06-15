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
    plausible-admin-password.file = ../../secrets/plausible.admin.password.age;
    plausible-keybase.file = ../../secrets/plausible.keybase.age;
    ghcr.file = ../../secrets/webby.ghcr.age;
    attic-env.file = ../../secrets/attic.env.age;
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
      adminUser = {
        email = "alexghr@users.noreply.github.com";
        passwordFile = config.age.secrets.plausible-admin-password.path;
      };

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

    atticd = {
      enable = true;

      credentialsFile = config.age.secrets.attic-env.path;

      settings = {
        listen = "[::]:8002";
        allowed-hosts = [
          "attic.alexghr.me"
        ];
        api-endpoint = "https://attic.alexghr.me/";

        database.url = "postgresql:///atticd?host=/run/postgresql&user=atticd";

        storage = {
          type = "local";
          path = "/var/lib/atticd/storage";
        };

        # basic chunking
        # taken from official docs
        # https://docs.attic.rs/admin-guide/deployment/nixos.html#configuration
        chunking = {
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };
  };

  systemd.services = {
    atticd-postgres = {
      after = [ "postgresql.service" ];
      partOf = [ "atticd.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = config.services.postgresql.superUser;
        RemainAfterExit = true;
      };
      script = ''
        PSQL() {
          ${config.services.postgresql.package}/bin/psql --port=5432 "$@"
        }
        # check if the database already exists
        if ! PSQL -lqt | ${pkgs.coreutils}/bin/cut -d \| -f 1 | ${pkgs.gnugrep}/bin/grep -qw atticd ; then
          PSQL -tAc "CREATE ROLE atticd WITH LOGIN;"
          PSQL -tAc "CREATE DATABASE atticd WITH OWNER atticd;"
        fi
      '';
      };

      atticd.after = [ "atticd-postgres.service" ];
  };

  alexghr.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
    exitNode = true;
  };
}
