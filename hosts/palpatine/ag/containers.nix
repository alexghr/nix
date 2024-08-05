{...}: {
  virtualisation.oci-containers = {
    backend = "docker";

    containers.aztec-sysbox = {
      image = "ghcr.io/alexghr/sysbox:latest";
      hostname = "aztec-sysbox";
      autoStart = true;
      user = "root";
      extraOptions = [
        "--privileged" 
        "--add-host" "aztec-sysbox:127.0.0.1"
        "--add-host" "aztec-sysbox:[::1]"
        "--add-host" "host.docker.internal:host-gateway"
      ];
      volumes = [
        "/home/ag/code/aztec:/workspaces"
        "user:/home/ubuntu"
      ];
    };
  };
}
