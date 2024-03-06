{
  pkgs,
  ...
}:
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/homepage-dashboard/settings.yaml - - - - ${./settings.yaml}"
    "L+ /var/lib/homepage-dashboard/services.yaml - - - - ${./services.yaml}"
    "L+ /var/lib/homepage-dashboard/bookmarks.yaml - - - - ${./bookmarks.yaml}"
    "L+ /var/lib/homepage-dashboard/widgets.yaml - - - - ${./widgets.yaml}"
  ];
}
