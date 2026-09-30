{config, ...}: {
  age.secrets.website_env.file = ../secrets/website_env.age;
  services.alexghr-me = {
    enable = true;
    environmentFile = config.age.secrets.website_env.path;
  };
}
