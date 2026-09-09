{config, ...}: {
  age.secrets.webdav_env.file = ../secrets/webdav_env.age;
  services.webdav = {
    enable = true;
    settings = {
      port = 6065;
      behindProxy = true;
      directory = "/webdav";
      permissions = "R";
      users = [
        {
          username = "ag";
          password = "{env}AG_PASSWORD";
          directory = "/webdav/users/ag";
          permissions = "CRUD";
        }
      ];
    };
    environmentFile = config.age.secrets.webdav_env.path;
  };
}
