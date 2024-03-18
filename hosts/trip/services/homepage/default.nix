{
  config,
  pkgs,
  ...
}:
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
  };

  age.secrets.uptimerobot.file = ../../secrets/uptimerobot.age;

  users.users.homepage-dashboard = {
    isSystemUser = true;
    home = "/var/lib/homepage-dashboard";
    group = "homepage-dashboard";
    extraGroups = [ "podman" ];
  };

  users.groups.homepage-dashboard = {};

  systemd.services.homepage-dashboard = {
    # explicitly add the `ping` binary to the service's PATH
    # otherwise the ping feature of Homepage won't work
    path = [
      pkgs.iputils
    ];

    serviceConfig = {
      User = "homepage-dashboard";
      Group = "homepage-dashboard";

      # load agenix secrets as credentials into systemd services
      # https://dee.underscore.world/blog/systemd-credentials-nixos-containers/
      LoadCredential = [
        "uptimerobot:${config.age.secrets.uptimerobot.path}"
      ];
      Environment = [
        "HOMEPAGE_FILE_UPTIMEROBOT_API_KEY=%d/uptimerobot"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/homepage-dashboard/settings.yaml - - - - ${./settings.yaml}"
    "L+ /var/lib/homepage-dashboard/services.yaml - - - - ${./services.yaml}"
    "L+ /var/lib/homepage-dashboard/bookmarks.yaml - - - - ${./bookmarks.yaml}"
    "L+ /var/lib/homepage-dashboard/widgets.yaml - - - - ${./widgets.yaml}"
    "L+ /var/lib/homepage-dashboard/docker.yaml - - - - ${./docker.yaml}"
  ];
}
