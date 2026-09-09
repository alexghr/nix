{lib, ...}: {
  flake.nixosModules.systemd-boot = {
    boot.loader = {
      systemd-boot = {
        enable = true;

        memtest86 = {
          enable = true;
          sortKey = "o_memtest86.conf";
        };
      };

      efi.canTouchEfiVariables = lib.mkDefault true;
      efi.efiSysMountPoint = lib.mkDefault "/boot";
    };
  };
}
