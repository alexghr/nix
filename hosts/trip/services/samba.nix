{
  config,
  pkgs,
  ...
}:
{
  users.users.ag.isNormalUser = true;

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    shares = {
      public = {
        path = "/mnt/shares/public";
        browseable = "yes";
        comment = "Public samba share.";
        "read only" = true;
        "guest ok" = "yes";
        "write list" = "ag";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      ag = {
        path = "/mnt/shares/ag";
        comment = "ag's private share.";
        browseable = false;
        "read only" = false;
        "guest ok" = false;
        "valid users" = "ag";
        "inherit permissions" = true;
        "fruit:aapl" = true;
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
