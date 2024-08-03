{...}: {
  virtualisation.oci-containers = {
    backend = "docker";

    containers.aztec-sysbox = {
      image = "ghcr.io/alexghr/aztec-sysbox:latest";
      hostname = "aztec-sysbox";
      autoStart = true;
      extraOptions = ["--privileged"];
      volumes = [
        "/home/ag/code/aztec:/workspaces"
        "user:/home/ubuntu"
      ];
    };
  };
}
