{
  config,
  pkgs,
  ...
}: {
  networking.firewall = {
    allowedTCPPorts = [4318];
  };

  services.caddy.virtualHosts."trip.spotted-gar.ts.net".extraConfig = ''
    handle_path /otel/* {
        reverse_proxy localhost:4318
    }
  '';

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.unstable.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        otlp.protocols.http.endpoint = "0.0.0.0:4318";
      };
      processors = {
        memory_limiter = {
          check_interval = "1s";
          limit_mib = 4096;
          spike_limit_mib = 1024;
        };
        batch = {};
      };
      exporters = {
        debug = {};
        prometheus = {
          endpoint = "127.0.0.1:8889";
          metric_expiration = "5m";
        };
        otlphttp = {
          endpoint = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/otlp";
        };
      };
      service.pipelines = {
        metrics = {
          receivers = ["otlp"];
          processors = ["memory_limiter" "batch"];
          exporters = ["debug" "prometheus"];
        };
        logs = {
          receivers = ["otlp"];
          processors = ["memory_limiter" "batch"];
          exporters = ["otlphttp"];
        };
      };
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "otel";
      static_configs = [
        {
          targets = ["127.0.0.1:8889"];
        }
      ];
    }
  ];
}
