{ config, pkgs, lib, ...}: let
  cfg = config.alexghr.b2-backup;
in with lib; {
  options.alexghr.b2-backup = {
    enable = mkEnableOption "backup configuration";

    bucket =  mkOption {
      type = types.str;
      description = "Bucket to backup to";
      example = "some-bucket";
    };

    bucketPath = mkOption {
      type = types.nullOr types.str;
      description = "Where to store the backup on the bucket";
      example = "/some-directory";
      default = "/${config.networking.hostName}";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      description = "Where to find the password";
      default = "/var/restic/password.txt";
    };

    environmentFile = mkOption {
      type = types.nullOr types.str;
      default = "/var/restic/b2.env";
      description = "Credentials to connect to the bucket";
    };

    paths = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = ["/"];
      description = "Which paths to backup. Defaults to `/`";
      example = ["/"];
    };

    exclude = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = [
        "/var/log"
        "/var/run"
        "/var/cache"
        "/var/tmp"
        "/nix"
        "/opt"
        "/usr"
        "/bin"
        "/sbin"
        "/run"
        "/proc"
        "/dev"
        "/boot"
        "/sys"
        "/tmp"
        "**/cache"
        "**/.cache"
        "**/node_modules"
      ];
      description = "Which paths avoid backing up";
      example = ["**/.cache"];
    };

    when = mkOption {
      type = types.nullOr types.str;
      description = "When to run the backup command";
      default = "00:01";
      example = "00:05";
    };
  };

  config = mkIf cfg.enable {
    services.restic.backups.b2 = {
      passwordFile = cfg.passwordFile;
      environmentFile = cfg.environmentFile;
      repository = "b2:${cfg.bucket}:${cfg.bucketPath}";
      paths = cfg.paths;
      extraBackupArgs = builtins.map (x: "--exclude ${x}") cfg.exclude;
      initialize = true;
      timerConfig = {
        OnCalendar = cfg.when;
      };
    };
  };
}
