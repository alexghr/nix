# nix run github:numtide/nixos-anywhere -- --flake .#b1droid root@<ip> --kexec "$(nix build --print-out-paths github:nix-community/nixos-images#packages.aarch64-linux.kexec-installer-nixos-2211-noninteractive)/nixos-kexec-installer-noninteractive-aarch64-linux.tar.gz"

{
 config,
 pkgs,
 lib,
 modulesPath,
 ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  system.stateVersion = "23.05";

  disko.devices = import ./disk-configuration.nix {
    inherit lib;
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 2048;
  }];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "btrfs" ];
  };

  networking = {
    hostName = "b1droid";
    firewall = {
      enable = true;
      allowedTCPPorts = [];
    };
  };

  nix = {
    package = pkgs.nixVersions.nix_2_13;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
    ];

    plausible = {
      group = "plausible";
      isSystemUser = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };

    # this comes with SSH jail by default
    fail2ban.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = false;
    };

    clickhouse = {
      enable = true;
      # package = pkgs.clickhouse.overrideAttrs (finalAttrs: previousAttrs: {
      #   cmakeFlags = previousAttrs.cmakeFlags ++ [
      #     "-DNO_ARMV81_OR_HIGHER=1"
      #   ];
      # });
    };
  };
}
