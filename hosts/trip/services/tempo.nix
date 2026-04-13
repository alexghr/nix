{config, ...}: {
  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3200;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9095;
      };

      distributor.receivers.otlp.protocols.http.endpoint = "127.0.0.1:4319";

      ingester.max_block_duration = "5m";

      compactor.compaction.block_retention = "168h";

      storage.trace = {
        backend = "local";
        wal.path = "/var/lib/tempo/wal";
        local.path = "/var/lib/tempo/blocks";
      };
    };
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Tempo";
      type = "tempo";
      uid = "tempo";
      access = "proxy";
      url = "http://127.0.0.1:${toString config.services.tempo.settings.server.http_listen_port}";
    }
  ];
}
