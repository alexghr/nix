{config, pkgs, ...}:
let
  mcpHttpAddr = "127.0.0.1";
  mcpHttpPort = "7824";
in
{
  services.forgejo = {
    enable = true;
    settings = {
      actions.ENABLED = true;
      session.COOKIE_SECURE = true;
      service = {
        DISABLE_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        REQUIRE_SIGNIN_VIEW = false;
        ENABLE_REVERSE_PROXY_AUTHENTICATION = false;
        ENABLE_REVERSE_PROXY_AUTHENTICATION_API = false;
        ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = false;
      };
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };
      oauth2_client.ENABLE_AUTO_REGISTRATION = false;
      server = {
        ROOT_URL = "https://forge.alexghr.me/";
        DOMAIN = "forge.alexghr.me";
        # SSH remains accessible over Tailscale, not the public HTTP tunnel.
        SSH_DOMAIN = "trip.spotted-gar.ts.net";
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
    # Retain the private endpoint for the runner's existing connection.
    redir /forgejo /forgejo/ 302
    handle_path /forgejo/* {
      reverse_proxy 127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}
    }
    handle_path /forgejo-mcp/* {
      reverse_proxy 127.0.0.1:7824
    }
  '';
}
