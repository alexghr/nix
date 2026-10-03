{config, ...}: let
  tunnelId = "f08f4e17-3129-4b73-92b4-09d512b1b24c";
in {
  age.secrets.cloudflare-tunnel.file = ../secrets/cloudflare-tunnel.age;

  services.cloudflared = {
    enable = true;
    tunnels.${tunnelId} = {
      credentialsFile = config.age.secrets.cloudflare-tunnel.path;
      ingress."www.alexghr.me" = "http://${config.services.alexghr-me.listenAddress}";
      default = "http_status:404";
    };
  };

  systemd.services."cloudflared-tunnel-${tunnelId}" = {
    wants = ["alexghr-me.service"];
    after = ["alexghr-me.service"];
  };
}
