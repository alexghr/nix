{config, ...}: {
  networking.firewall = {
    allowedTCPPorts = [8080 43210];
    allowedUDPPorts = [43210];
  };

  age.secrets.aztec-alpha-val1.file = ../secrets/aztec-alpha-val1.age;

  virtualisation.oci-containers.containers = {
    aztec-alpha-val1 = {
      image = "aztecprotocol/aztec:0.84.0-alpha-testnet.2";
      entrypoint = "/bin/bash";
      cmd = [
        "-c"
        ''
          node /usr/src/yarn-project/aztec/dest/bin/index.js start --node --archiver --sequencer
        ''
      ];
      ports = [
        "8080:8080/tcp"
        "43210:43210/tcp"
        "43210:43210/udp"
      ];
      environment = {
        ETHEREUM_SLOT_DURATION = "12";
        AZTEC_SLOT_DURATION = "36";
        AZTEC_EPOCH_DURATION = "32";
        AZTEC_PROOF_SUBMISSION_WINDOW = "64";
        PROVER_REAL_PROOFS = "true";

        L1_CHAIN_ID = "11155111";
        REGISTRY_CONTRACT_ADDRESS = "0x4d2cc1d5fb6be65240e0bfc8154243e69c0fb19e";
        SLASH_FACTORY_CONTRACT_ADDRESS = "0xef057a24cb08c15321c7875f18e904e5131436aa";
        FEE_ASSET_HANDLER_CONTRACT_ADDRESS = "0x80d848dc9f52df56789e2d62ce66f19555ff1019";

        TEST_ACCOUNTS = "false";
        SPONSORED_FPC = "true";

        LOG_LEVEL = "debug; info: aztec:simulator, json-rpc";
        LOG_JSON = "true";
        DATA_DIRECTORY = "/var/lib/aztec";
        VALIDATOR_DISABLED = "false";
        SEQ_MIN_TX_PER_BLOCK = "0";
        SEQ_MAX_TX_PER_BLOCK = "0";
        ARCHIVER_POLLING_INTERVAL_MS = "1000";
        ARCHIVER_VIEM_POLLING_INTERVAL_MS = "1000";
        L1_READER_VIEM_POLLING_INTERVAL_MS = "1000";
        SEQ_VIEM_POLLING_INTERVAL_MS = "1000";
	SENTINEL_ENABLED = "true";

        P2P_PORT = "43210";
        P2P_QUERY_FOR_IP = "true";
        P2P_ENABLED = "true";
        P2P_GOSSIPSUB_FLOOD_PUBLISH = "true";
        P2P_BOOTSTRAP_NODES_AS_FULL_PEERS = "false";
        BOOTSTRAP_NODES = "enr:-LO4QLbJddVpePYjaiCftOBY-L7O6Mfj_43TAn5Q1Y-5qQ_OWmSFc7bTKWHzw5xmdVIqXUiizum_kIRniXdPnWHHcwEEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEI8nh9YlzZWNwMjU2azGhA-_dX6aFcXP1DLk91negbXL2a0mNYGXH4hrMvb2i92I0g3VkcIKd0A,enr:-LO4QN4WF8kFyV3sQVX0C_y_03Eepxk5Wac70l9QJcIDRYwKS6aRst1YcfbTDdvovXdRfKf-WSXNVWViGLhDA-dUz2MEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEIicTHolzZWNwMjU2azGhAsz7aFFYRnP5xjTux5UW-HyEQcW_EJrZMT1CNm79N4g-g3VkcIKd0A,enr:-LO4QFrGfkRaCk_iFTeUjR5ESwo45Eov9hx_T1-BLdoT-iHzFgCiHMT4V1KBtdFp8D0ajLSe5HcNYrhalmdJXgv6NTUEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEIlICt4lzZWNwMjU2azGhAlC6nKB3iDtRFqWKWqxf_t-P9hc-SZ6VFBJV4y3bTZBQg3VkcIKd0A";

        NODE_NO_WARNINGS = "1";
      };
      environmentFiles = [config.age.secrets.aztec-alpha-val1.path];
      volumes = [
        "/var/lib/aztec/aztec-alpha-val1:/var/lib/aztec"
      ];
    };
  };
}
