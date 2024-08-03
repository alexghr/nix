{
  config,
  pkgs,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [ 53 8081 ];
    allowedUDPPorts = [ 53 ];
  };

  services.tandoor-recipes = {
    enable = true;
    port = 8090;
  };
}
