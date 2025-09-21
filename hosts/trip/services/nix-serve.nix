{config, ...}: {
  age.secrets.nix-serve-private-key.file = ../secrets/nix-serve-private-key.age;
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.nix-serve-private-key.path;
  };

  #services.blocky.settings.customDNS.mapping."nixcache.esrever.uno" = "10.1.1.110";
  #services.caddy.virtualHosts."nixcache.esrever.uno" = {
  #  extraConfig = ''
  #    reverse_proxy :${builtins.toString config.services.nix-serve.port}
  #  '';
  #};
}
