{config, ...}:
{
  services.forgejo = {
    enable = true;
    settings = {
      session.COOKIE_SECURE = true;
      server = {
        ROOT_URL = "https://trip.spotted-gar.ts.net/forgejo/";
        DOMAIN = "trip.spotted-gar.ts.net";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 7823;
        PROTOCOL = "http";
      };
    };
  };
  services.caddy.virtualHosts."trip.spotted-gar.ts.net".extraConfig = ''
    redir /forgejo /forgejo/ 302
    handle_path /forgejo/* {
      reverse_proxy 127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}
    }
  '';
}
