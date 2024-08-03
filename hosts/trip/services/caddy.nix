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
    package = packages.caddyCF;
    globalConfig = ''
      acme_dns cloudflare {env.CF_DNS_API_TOKEN}
    '';

    virtualHosts = {
      "trip.esrever.uno" = {
        extraConfig = ''
          reverse_proxy :${builtins.toString config.services.homepage-dashboard.listenPort}
        '';
      };

      "hass.esrever.uno" = {
        extraConfig = ''
          reverse_proxy :${builtins.toString config.services.home-assistant.config.http.server_port}
        '';
      };

      "tandoor.esrever.uno" = {
        extraConfig = ''
          reverse_proxy :${builtins.toString config.services.tandoor-recipes.port}
        '';
      };

      "unifi.esrever.uno" = {
        extraConfig = ''
          reverse_proxy {
            to https://:8443
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
    };
  };
}
