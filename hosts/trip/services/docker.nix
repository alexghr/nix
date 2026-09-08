{...}: {
  services.dockerRegistry = {
    enable = true;
    port = 5001;
    extraConfig = {
      proxy.remoteurl = "https://registry-1.docker.io";
      delete = true;
    };
  };
}
