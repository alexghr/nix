{config, pkgs, ...}: {
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
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
    email = "{env.ADMIN_EMAIL}";

    virtualHosts = {
      "trip.spotted-gar.ts.net".extraConfig = ''
        tls {
          get_certificate tailscale
        }
      '';
    };
  };
}
