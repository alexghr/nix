{
  config,
  pkgs,
  packages,
  lib,
  alexghrKeys,
  modulesPath,
  nixosModules,
  ...
}: {
  imports = [
    nixosModules.nix
    nixosModules.agenix
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;

  system.stateVersion = "23.11";
  time.timeZone = "Europe/London";

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  powerManagement = {
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  users.users.root.openssh.authorizedKeys.keys = alexghrKeys;

  networking = {
    hostName = "drk-1";
    networkmanager.enable = true;
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8080
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    lsof
    lm_sensors
    libraspberrypi
    podman
    podman-compose
  ];

  services = {
    openssh.enable = true;
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
    };
    oci-containers = {
      backend = "podman";
      containers = {
        homer = {
          image = "b4bz/homer";
          ports = [
            "8080:8080"
          ];
          volumes = [
            "/var/containers/homer/assets:/www/assets"
          ];
          environment = {
            INIT_ASSETS = "1";
          };
        };
      };
    };
  };
}
