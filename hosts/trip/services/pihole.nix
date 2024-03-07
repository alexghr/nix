{
  config,
  pkgs,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [ 53 8081 ];
    allowedUDPPorts = [ 53 ];
  };

  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "8081:80/tcp"
      ];
      environment = {
        TZ = "Europe/London";
        PIHOLE_DNS_ = "1.1.1.1; 1.0.0.1";
      };
      volumes = [
        "/var/lib/pihole:/etc/pihole"
      ];
    };
  };
}
