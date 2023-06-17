{ ... }:
{
  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "alexghr.me" = {
        locations."/" = {
          return = "307 https://www.alexghr.me$request_uri";
        };
      };
      "www.alexghr.me" = {
        locations."/" = {
          proxyPass = "http://localhost:8001";
        };
      };
      "plausible.alexghr.me" = {
        locations."/" = {
          proxyPass = "http://localhost:8000";
        };
      };
      "attic.alexghr.me" = {
        locations."/" = {
          proxyPass = "http://localhost:8002";
          extraConfig = ''
            client_max_body_size 100M;
            proxy_set_header Host $host;
          '';
        };
      };
    };
    };
}
