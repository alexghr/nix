{
  config,
  pkgs,
  lib,
  packages,
  ...
}: {
  # let caddy reuse certificates from tailscale
  services.tailscale.permitCertUid = builtins.toString config.users.users.caddy.uid;
  networking.firewall.allowedTCPPorts = [80 443];

  age.secrets.caddy.file = ../secrets/caddy.age;

  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.caddy.path;
    };
  };

  services.caddy = {
    enable = true;
    email = "{env.ADMIN_EMAIL}";
    globalConfig = ''
    '';

    virtualHosts = {
      "trip.spotted-gar.ts.net" = {};
    };
  };
}
