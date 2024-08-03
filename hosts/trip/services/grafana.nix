{
  config,
  pkgs,
  ...
}: {
  networking.firewall = {
    allowedTCPPorts = [2342];
  };

  services.blocky.settings.customDNS.mapping."grafana.esrever.uno" = "10.1.1.110";
  services.caddy.virtualHosts."grafana.esrever.uno" = {
    extraConfig = ''
      reverse_proxy :${builtins.toString config.services.grafana.settings.server.http_port}
    '';
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 2342;
      http_addr = "127.0.0.1";
    };

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
