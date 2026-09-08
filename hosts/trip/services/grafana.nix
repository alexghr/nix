{config, ...}: {
  networking.firewall = {
    allowedTCPPorts = [2342];
  };

  services.caddy.virtualHosts."trip.spotted-gar.ts.net".extraConfig = ''
    reverse_proxy /grafana :${builtins.toString config.services.grafana.settings.server.http_port}
    reverse_proxy /grafana/* :${builtins.toString config.services.grafana.settings.server.http_port}
  '';

  services.grafana = {
    enable = true;
    provision.enable = true;
    settings.server = {
      http_port = 2342;
      http_addr = "127.0.0.1";
      root_url = "https://trip.spotted-gar.ts.net/grafana";
      serve_from_sub_path = true;
    };

    # Grafana gives no way to rotate and this was the default key that was setup by previous NixOS versions
    # upgrade notes https://nixos.org/manual/nixos/stable/release-notes#sec-release-26.05-incompatibilities
    settings.security.secret_key = "SW2YcwTIb9zpOOhoPsMm";

    settings.panels.disable_sanitize_html = true;
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "trip";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
}
