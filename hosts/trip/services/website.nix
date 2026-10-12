{config, ...}: {
  age.secrets.website_env.file = ../secrets/website_env.age;
  services.alexghr-me = {
    enable = true;
    environmentFile = config.age.secrets.website_env.path;
    environment = {
      PUBLIC_URL = "https://www.alexghr.me";
    };
  };

  environment.systemPackages = [
    config.services.alexghr-me.package # add mkpost
  ];
}
