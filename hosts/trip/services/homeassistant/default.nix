{pkgs, ...}: {
  # Create directory for VM images
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images/homeassistant 0755 root libvirtd -"
  ];

  systemd.services.homeassistant-vm = {
    description = "Home Assistant Virtual Machine";
    after = ["libvirtd.service" "network-online.target"];
    wants = ["libvirtd.service" "network-online.target"];
    wantedBy = ["multi-user.target"];

    restartIfChanged = false;
    stopIfChanged = false;

    script = ''
      export LC_ALL=C
      virsh() { ${pkgs.libvirt}/bin/virsh --connect qemu:///system "$@"; }

      virsh net-autostart bridged-network
      if ! virsh net-list --name | ${pkgs.gnugrep}/bin/grep -Fxq bridged-network; then
        virsh net-start bridged-network
      fi
      if [ "$(virsh domstate homeassistant)" != running ]; then
        virsh start homeassistant
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.libvirt}/bin/virsh --connect qemu:///system shutdown homeassistant";
      Restart = "on-failure";
      RestartSec = "10s";
      TimeoutStopSec = "120";
    };
  };
}
