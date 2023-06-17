{ ... }:
{
  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    recommendedProxySettings = true;

    commonHttpConfig = ''
      # Cloudflare IPv4 ranges https://www.cloudflare.com/ips-v4
      set_real_ip_from 173.245.48.0/20;
      set_real_ip_from 103.21.244.0/22;
      set_real_ip_from 103.22.200.0/22;
      set_real_ip_from 103.31.4.0/22;
      set_real_ip_from 141.101.64.0/18;
      set_real_ip_from 108.162.192.0/18;
      set_real_ip_from 190.93.240.0/20;
      set_real_ip_from 188.114.96.0/20;
      set_real_ip_from 197.234.240.0/22;
      set_real_ip_from 198.41.128.0/17;
      set_real_ip_from 162.158.0.0/15;
      set_real_ip_from 104.16.0.0/13;
      set_real_ip_from 104.24.0.0/14;
      set_real_ip_from 172.64.0.0/13;
      set_real_ip_from 131.0.72.0/22;

      # Cloudflare IPv6 ranges https://www.cloudflare.com/ips-v6
      set_real_ip_from 2400:cb00::/32;
      set_real_ip_from 2606:4700::/32;
      set_real_ip_from 2803:f800::/32;
      set_real_ip_from 2405:b500::/32;
      set_real_ip_from 2405:8100::/32;
      set_real_ip_from 2a06:98c0::/29;
      set_real_ip_from 2c0f:f248::/32;

      # Clouflare header https://developers.cloudflare.com/fundamentals/get-started/reference/http-request-headers/#cf-connecting-ip
      real_ip_header CF-Connecting-IP;

      log_format main '$remote_addr - $remote_user [$time_local] '
                      '"$host" "$request" $status $body_bytes_sent $request_time '
                      '"$http_referer" "$http_user_agent"';
      access_log /var/log/nginx/access.log main;
    '';

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
