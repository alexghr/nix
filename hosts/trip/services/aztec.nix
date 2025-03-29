{config, ...}: {
  networking.firewall = {
    allowedTCPPorts = [8080 43210];
    allowedUDPPorts = [43210];
  };

  age.secrets.aztec-alpha-val1.file = ../secrets/aztec-alpha-val1.age;

  virtualisation.oci-containers.containers = {
    aztec-alpha-val1 = {
      image = "aztecprotocol/aztec:0.82.2-alpha-testnet.5";
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

        L1_CHAIN_ID = "11155111";
        VERSION = "3";
        ROLLUP_ADDRESS = "0xee29e2cfdf6bac577e7a6497a6d61856be22c9f1";
        REGISTRY_CONTRACT_ADDRESS = "0xad85d55a4bbef35e95396191c22903aa717edf1c";

        TEST_ACCOUNTS = "false";
        SPONSORED_FPC = "true";

        LOG_LEVEL = "debug";
        LOG_JSON = "true";
        DATA_DIRECTORY = "/var/lib/aztec";
        VALIDATOR_DISABLED = "false";
        SEQ_MIN_TX_PER_BLOCK = "0";
        ARCHIVER_POLLING_INTERVAL_MS = "1000";
        ARCHIVER_VIEM_POLLING_INTERVAL_MS = "1000";
        L1_READER_VIEM_POLLING_INTERVAL_MS = "1000";
        SEQ_VIEM_POLLING_INTERVAL_MS = "1000";

        P2P_PORT = "43210";
        P2P_ENABLED = "true";
        P2P_GOSSIPSUB_FLOOD_PUBLISH = "true";
        P2P_BOOTSTRAP_NODES_AS_FULL_PEERS = "false";
        BOOTSTRAP_NODES = "enr:-LO4QLbJddVpePYjaiCftOBY-L7O6Mfj_43TAn5Q1Y-5qQ_OWmSFc7bTKWHzw5xmdVIqXUiizum_kIRniXdPnWHHcwEEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEI8nh9YlzZWNwMjU2azGhA-_dX6aFcXP1DLk91negbXL2a0mNYGXH4hrMvb2i92I0g3VkcIKd0A,enr:-LO4QN4WF8kFyV3sQVX0C_y_03Eepxk5Wac70l9QJcIDRYwKS6aRst1YcfbTDdvovXdRfKf-WSXNVWViGLhDA-dUz2MEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEIicTHolzZWNwMjU2azGhAsz7aFFYRnP5xjTux5UW-HyEQcW_EJrZMT1CNm79N4g-g3VkcIKd0A,enr:-LO4QFrGfkRaCk_iFTeUjR5ESwo45Eov9hx_T1-BLdoT-iHzFgCiHMT4V1KBtdFp8D0ajLSe5HcNYrhalmdJXgv6NTUEhWF6dGVjqDAwLTExMTU1MTExLTAwMDAwMDAwLTAtMTgwNmEwMjgtMWE1MzBmM2KCaWSCdjSCaXCEIlICt4lzZWNwMjU2azGhAlC6nKB3iDtRFqWKWqxf_t-P9hc-SZ6VFBJV4y3bTZBQg3VkcIKd0A";

        NODE_NO_WARNINGS = "1";
      };
      environmentFiles = [config.age.secrets.aztec-alpha-val1.path];
      volumes = [
        "/var/lib/aztec-alpha-val1:/data"
      ];
    };
  };
}
