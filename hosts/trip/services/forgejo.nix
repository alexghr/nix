{
  config,
  lib,
  pkgs,
  ...
}: let
  forgejo-mcp = pkgs.unstable.callPackage ../../../packages/forgejo-mcp.nix {};
  mcpHttpAddr = "127.0.0.1";
  mcpHttpPort = "7824";
  signingDir = "${config.services.forgejo.stateDir}/signing";
  signingKey = "${signingDir}/ed25519";
in {
  services.openssh.extraConfig = ''
    Match User forgejo
      AuthenticationMethods publickey
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    Match all
  '';

  services.forgejo = {
    enable = true;
    settings = {
      actions.ENABLED = true;
      session.COOKIE_SECURE = true;
      "repository.signing" = {
        FORMAT = "ssh";
        SIGNING_KEY = "${signingKey}.pub";
        SIGNING_NAME = "Forgejo";
        SIGNING_EMAIL = "forgejo@forge.alexghr.me";
        INITIAL_COMMIT = "always";
        WIKI = "always";
        CRUD_ACTIONS = "always";
        MERGES = "always";
      };
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
        SSH_DOMAIN = "forge.alexghr.me";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 7823;
        PROTOCOL = "http";
      };
    };
  };

  systemd.services.forgejo = {
    path = [pkgs.openssh];
    preStart = lib.mkBefore ''
      (
        umask 077
        mkdir -p '${signingDir}'
        chmod 700 '${signingDir}'
        if [ ! -e '${signingKey}' ]; then
          ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" \
            -C 'Forgejo commit signing' -f '${signingKey}'
        fi
        chmod 600 '${signingKey}'
        ${pkgs.openssh}/bin/ssh-keygen -y -f '${signingKey}' > '${signingKey}.pub'
        chmod 644 '${signingKey}.pub'
      )
    '';
  };

  systemd.services.forgejo-mcp = {
    description = "Forgejo MCP server";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "forgejo.service"];
    serviceConfig = {
      ExecStart = "${forgejo-mcp}/bin/forgejo-mcp --transport http --host ${mcpHttpAddr} --http-port ${mcpHttpPort} --allowed-hosts trip.spotted-gar.ts.net,forge.alexghr.me --url http://127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  services.caddy.virtualHosts."forge.alexghr.me".extraConfig = ''
    tls {
      dns cloudflare {env.CF_DNS_API_TOKEN}
      resolvers 1.1.1.1 1.0.0.1
    }
    handle /mcp {
      reverse_proxy 127.0.0.1:${mcpHttpPort}
    }
    handle {
      reverse_proxy 127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}
    }
  '';

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
