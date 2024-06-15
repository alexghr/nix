{
  config,
  pkgs,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "blocky.trip";
      static_configs = [{
        targets = [ "127.0.0.1:${toString config.services.blocky.settings.ports.http}" ];
      }];
    }
  ];

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

      ports.http = 4000;
      prometheus.enable = true;
      customDNS.mapping = {
        "hass.esrever.uno" = "10.1.1.110";
      };
    };
  };
}
