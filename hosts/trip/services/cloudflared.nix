{config, ...}: {
  age.secrets = {
    ghcr.file = ../secrets/ghcr.age;
    cloudflared = {
      file = ../secrets/cloudflared.age;
      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;
    };
  };

  virtualisation.oci-containers.containers = {
    alexghr = {
      image = "ghcr.io/alexghr/www";
      login = {
        username = "alexghr";
        passwordFile = config.age.secrets.ghcr.path;
        registry = "ghcr.io";
      };
      ports = [
        "8080:80"
      ];
    };
  };

  services.cloudflared.enable = true;
  services.cloudflared.tunnels."c7c61e3d-0b6d-4ee5-9129-b8a5f7019f80" = {
    credentialsFile = config.age.secrets.cloudflared.path;
    default = "http_status:404";
    ingress = {
      "new.alexghr.me" = {
        service = "http://127.0.0.1:8080";
      };
    };
  };
}
