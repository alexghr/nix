{
  config,
  lib,
  pkgs,
  ...
}: let
  runnerHome = "/var/lib/forgejo-runner";
  runnerConfig = (pkgs.formats.yaml {}).generate "forgejo-runner.yaml" {
    runner = {
      capacity = 1;
      labels = ["nix:host"];
    };
    host.workdir_parent = "${runnerHome}/work";
    server.connections.trip = {
      url = "https://trip.spotted-gar.ts.net/forgejo/";
      uuid = "64343335-3032-3064-3135-353836366432";
      token_url = "file:$CREDENTIALS_DIRECTORY/runner-token";
    };
  };
in {
  system.stateVersion = "26.05";
  networking.hostName = "forgejo-ci";
  services.getty.autologinUser = "root";
  # Console-only administration
  users.users.root.initialHashedPassword = "";
  boot.kernelModules = ["qemu_fw_cfg"];

  virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 102400; # 100GB
    graphics = false;
    qemu.forceAccel = true;
    useNixStoreImage = true;
    mountHostNixStore = false;
    writableStore = true;
    writableStoreUseTmpfs = false;
    sharedDirectories = lib.mkForce {};
    qemu.options = [
      "-fw_cfg name=opt/forgejo-runner-token,file=\"$CREDENTIALS_DIRECTORY/runner-token\""
      "-qmp unix:\"$NIX_DISK_IMAGE.qmp\",server=on,wait=off"
    ];
  };

  users.groups.forgejo-runner = {};
  users.users.forgejo-runner = {
    isSystemUser = true;
    group = "forgejo-runner";
    home = runnerHome;
  };

  systemd.services.forgejo-runner = {
    description = "Forgejo Actions runner";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target" "systemd-modules-load.service" "nix-daemon.socket"];
    environment.HOME = runnerHome;
    path = with pkgs; [
      bash
      coreutils
      curl
      gawk
      git
      gnugrep
      gnused
      gnutar
      gzip
      config.nix.package
      nodejs
      openssh
      unzip
      wget
      unstable.devenv
      cachix
    ];
    serviceConfig = {
      User = "forgejo-runner";
      Group = "forgejo-runner";
      StateDirectory = "forgejo-runner";
      WorkingDirectory = runnerHome;
      LoadCredential = "runner-token:/sys/firmware/qemu_fw_cfg/by_name/opt/forgejo-runner-token/raw";
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config ${runnerConfig}";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
      ProtectHome = true;
      PrivateTmp = true;
    };
  };
}
