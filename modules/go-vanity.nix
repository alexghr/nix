{...}: {
  flake.nixosModules.go-vanity = {
    lib,
    config,
    ...
  }: let
    cfg = config.services.goVanity;
  in {
    options.services.goVanity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      domain = lib.mkOption {
        type = lib.types.str;
      };
      repository = lib.mkOption {
        type = lib.types.str;
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 7825;
      };
    };
    config = lib.mkIf cfg.enable {
      # Assumes TLS termination happens upstream
      services.caddy.virtualHosts."http://:${toString cfg.port}".extraConfig = ''
        bind 127.0.0.1

        @module {
          query go-get=1
          path_regexp repo ^/([A-Za-z0-9._-]+)(/.*)?$
        }

        handle @module {
          header Content-Type "text/html; charset=utf-8"
          respond <<HTML
            <!doctype html>
            <html>
              <head>
                <meta name="go-import" content="${cfg.domain}/{re.repo.1} git ${cfg.repository}/{re.repo.1}">
              </head>
            </html>
            HTML 200
        }

        @discovery query go-get=1
        handle @discovery {
          respond "Module path required" 404
        }

        handle {
          redir ${cfg.repository}{uri} 302
        }
      '';
    };
  };
}
