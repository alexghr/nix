{config, pkgs, ...}:
let
  mcpHttpAddr = "127.0.0.1";
  mcpHttpPort = "7824";
in
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

  systemd.services.forgejo-mcp = {
    description = "Forgejo MCP server";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "forgejo.service"];
    serviceConfig = {
      ExecStart = "${pkgs.unstable.forgejo-mcp}/bin/forgejo-mcp --transport http --host ${mcpHttpAddr} --http-port ${mcpHttpPort} --allowed-hosts trip.spotted-gar.ts.net --url http://127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  services.caddy.virtualHosts."trip.spotted-gar.ts.net".extraConfig = ''
    redir /forgejo /forgejo/ 302
    handle_path /forgejo/* {
      reverse_proxy 127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}
    }
    handle_path /forgejo-mcp/* {
      reverse_proxy 127.0.0.1:7824
    }
  '';
}
