{
  config,
  pkgs,
  ...
}: let
  apiPort = 4000;
in {
  networking.firewall = {
    allowedTCPPorts = [53 apiPort];
    allowedUDPPorts = [53];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "blocky.trip";
      static_configs = [
        {
          targets = ["127.0.0.1:${toString apiPort}"];
        }
      ];
    }
  ];

  services.caddy.virtualHosts."blocky.esrever.uno".extraConfig = ''
    reverse_proxy :${toString apiPort}
  '';

  services.blocky = {
    enable = true;
    settings = {
      upstreams = {
        groups.default = [
          "1.1.1.1"
          "8.8.8.8"
          "9.9.9.9"
        ];
      };
      blocking = {
        blackLists.ads = [
          "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
          # "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          # "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt"
          # enable this once blocky updates to v0.23
          # "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"
        ];
        clientGroupsBlock.default = ["ads"];
      };

      caching = {
        # respect TTL
        minTime = "0m";
        maxTime = "0m";
        prefetching = true;

        # cache NXDOMAIN responses for 5 minutes
        cacheTimeNegative = "5m";
      };

      ports.http = "0.0.0.0:${toString apiPort}";
      prometheus.enable = true;
      customDNS = {
        filterUnmappedTypes = false;
        rewrite = {
          "home" = "localdomain";
        };
        mapping = {
          "mackey.localdomain" = "10.1.1.116";
          "palpatine.localdomain" = "10.1.1.105";
          "trip.localdomain" = "10.1.1.110";
          "unifi.localdomain" = "10.1.1.1";
          "esrever.uno" = "10.1.1.110";
        };
      };
    };
  };
}
