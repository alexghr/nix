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
    # see packages/caddy/default.nix
    # package = packages.caddyCF;
    # acme_dns cloudflare {env.CF_DNS_API_TOKEN}
    # tailscale cert trip.spotted-gar.ts.net
    globalConfig = ''
    '';

    # reverse_proxy / :${builtins.toString config.services.homepage-dashboard.listenPort}
    virtualHosts = {
      "trip.spotted-gar.ts.net" = {
        #extraConfig = ''
        #  reverse_proxy :${builtins.toString config.services.grafana.settings.server.http_port}
        #'';
      };
    };
  };
}
