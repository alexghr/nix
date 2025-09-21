{config, ...}: {
  services.blocky.settings.customDNS.mapping."docker.esrever.uno" = "10.1.1.110";
  #services.caddy.virtualHosts."docker.esrever.uno" = {
  #  extraConfig = ''
  #    reverse_proxy :${builtins.toString config.services.dockerRegistry.port}
  #  '';
  #};
  services.dockerRegistry = {
    enable = true;
    port = 5001;
    extraConfig = {
      proxy.remoteurl = "https://registry-1.docker.io";
      delete = true;
    };
  };
}
