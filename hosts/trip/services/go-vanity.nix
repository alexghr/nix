{nixosModules, ...}: {
  imports = [nixosModules.go-vanity];

  services.goVanity = {
    enable = true;
    domain = "go.alexghr.me";
    repository = "https://github.com/alexghr";
  };
}
