{config, packages, ...}: {
  networking.firewall = {
    allowedTCPPorts = [8080 43210 43211 9229 43212];
    allowedUDPPorts = [43210 43211 9229 43212];
  };

  age.secrets.aztec-alpha-val1.file = ../secrets/aztec-alpha-val1.age;
  age.secrets.aztec-staging.file = ../secrets/aztec-staging.age;
  age.secrets.aztec-mainnet.file = ../secrets/aztec-mainnet.age;

  services.caddy.virtualHosts."trip.spotted-gar.ts.net".extraConfig = ''
    handle_path /aztec/mainnet {
      reverse_proxy :8080
    }
    handle_path /aztec/testnet {
      reverse_proxy :8081
    }
  '';

  virtualisation.oci-containers.containers = {
    aztec-mainnet = {
      image = "aztecprotocol/aztec:2.1.9";
      pull = "always";
      entrypoint = "/bin/bash";
      cmd = [
        "-c"
        ''
          env
          node /usr/src/yarn-project/aztec/dest/bin/index.js start --node --archiver --network mainnet
        ''
      ];
      ports = [
        "8080:8080/tcp"
        "43212:43212/tcp"
        "43212:43212/udp"
      ];
      environment = {
        LOG_LEVEL = "info";
        LOG_JSON = "true";
        DATA_DIRECTORY = "/var/lib/aztec";
        ARCHIVER_POLLING_INTERVAL_MS = "1000";
        ARCHIVER_VIEM_POLLING_INTERVAL_MS = "1000";
        L1_READER_VIEM_POLLING_INTERVAL_MS = "1000";
        SEQ_VIEM_POLLING_INTERVAL_MS = "1000";
        SENTINEL_ENABLED = "true";

        P2P_PORT = "43212";
        P2P_QUERY_FOR_IP = "true";
        P2P_ENABLED = "true";

        NODE_NO_WARNINGS = "1";
        OTEL_EXPORTER_OTLP_METRICS_ENDPOINT = "http://host.docker.internal:4318/v1/metrics";
        OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = "http://host.docker.internal:4318/v1/logs";
        OTEL_SERVICE_NAME = "mainnet-gb";
      };
      environmentFiles = [config.age.secrets.aztec-mainnet.path];
      extraOptions = ["--add-host" "host.docker.internal:host-gateway" ];
      volumes = [
        "/var/lib/aztec/aztec-mainnet:/var/lib/aztec"
      ];
    };

    aztec-testnet = {
      image = "aztecprotocol/aztec:latest";
      pull = "always";
      entrypoint = "/bin/bash";
      cmd = [
        "-c"
        ''
          node /usr/src/yarn-project/aztec/dest/bin/index.js start --node --archiver --sequencer --network testnet
        ''
      ];
      ports = [
        "8081:8080/tcp"
        "43211:43211/tcp"
        "43211:43211/udp"
      ];
      environment = {
        LOG_LEVEL = "info";
        LOG_JSON = "true";
        DATA_DIRECTORY = "/var/lib/aztec";
        VALIDATOR_DISABLED = "false";
        SEQ_MIN_TX_PER_BLOCK = "0";
        SEQ_MAX_TX_PER_BLOCK = "8";
        ARCHIVER_POLLING_INTERVAL_MS = "1000";
        ARCHIVER_VIEM_POLLING_INTERVAL_MS = "1000";
        L1_READER_VIEM_POLLING_INTERVAL_MS = "1000";
        SEQ_VIEM_POLLING_INTERVAL_MS = "1000";
        SENTINEL_ENABLED = "true";

        P2P_PORT = "43211";
        P2P_QUERY_FOR_IP = "true";
        P2P_ENABLED = "true";
        P2P_GOSSIPSUB_FLOOD_PUBLISH = "false";
        P2P_BOOTSTRAP_NODES_AS_FULL_PEERS = "false";

        NODE_NO_WARNINGS = "1";
        OTEL_EXPORTER_OTLP_METRICS_ENDPOINT = "http://host.docker.internal:4318/v1/metrics";
        OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = "http://host.docker.internal:4318/v1/logs";
        OTEL_SERVICE_NAME = "staging-public-validator";
      };
      environmentFiles = [config.age.secrets.aztec-staging.path];
      extraOptions = ["--add-host" "host.docker.internal:host-gateway"];
      volumes = [
        "/var/lib/aztec/aztec-public-staging:/var/lib/aztec"
      ];
    };
  };
}
