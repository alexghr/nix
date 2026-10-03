{
  config,
  lib,
  pkgs,
  ...
}: let
  vmHome = "/var/lib/forgejo-runner-vm";
  guest = import "${pkgs.path}/nixos/lib/eval-config.nix" {
    inherit pkgs;
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"
      ./forgejo-runner-guest.nix
      {
        time.timeZone = config.time.timeZone;
        nix.settings =
          config.nix.settings
          // {
            max-jobs = 1;
            cores = 4;
          };
        nix.gc = config.nix.gc;
      }
    ];
  };
  stopVm = pkgs.writeShellScript "stop-forgejo-runner-vm" ''
    printf '%s\n' '{"execute":"qmp_capabilities"}' '{"execute":"system_powerdown"}' \
      | ${pkgs.socat}/bin/socat -t 1 - UNIX-CONNECT:${vmHome}/ci.qcow2.qmp || true
    # Allow the guest to shut down and flush its persistent disk before SIGTERM.
    for attempt in {1..90}; do
      kill -0 "$MAINPID" 2>/dev/null || exit 0
      sleep 1
    done
  '';
in {
  age.secrets.forgejo-runner.file = ./secrets/forgejo-runner.age;

  users.groups.forgejo-runner-vm = {};
  users.users.forgejo-runner-vm = {
    isSystemUser = true;
    group = "forgejo-runner-vm";
    home = vmHome;
  };

  systemd.services.forgejo-runner-vm = {
    description = "NixOS VM for Forgejo Actions (8 GiB, 4 vCPUs)";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target" "tailscaled.service"];
    after = ["network-online.target" "tailscaled.service"];
    environment.NIX_DISK_IMAGE = "${vmHome}/ci.qcow2";
    serviceConfig = {
      User = "forgejo-runner-vm";
      Group = "forgejo-runner-vm";
      SupplementaryGroups = ["kvm"];
      StateDirectory = "forgejo-runner-vm";
      StateDirectoryMode = "0700";
      WorkingDirectory = vmHome;
      LoadCredential =
        lib.optional (config.age.secrets ? forgejo-runner)
        "runner-token:${config.age.secrets.forgejo-runner.path}";
      ExecStart = "${guest.config.system.build.vm}/bin/run-forgejo-ci-vm";
      ExecStop = stopVm;
      TimeoutStopSec = "120s";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      PrivateTmp = true;
      UMask = "0077";
      Nice = 10;
    };
  };
}
