{
  config,
  pkgs,
  lib,
  ...
}: {
  # Create directory for VM images
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images/homeassistant 0755 root libvirtd -"
  ];

  systemd.services.homeassistant-vm = {
    description = "Home Assistant Virtual Machine";
    after = ["libvirtd.service" "network.target"];
    wants = ["libvirtd.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.libvirt}/bin/virsh start homeassistant || exit 0";
      ExecStop = "${pkgs.libvirt}/bin/virsh shutdown homeassistant";
      TimeoutStopSec = "120";
    };
  };
}
