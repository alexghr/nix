{lib, ...}: let
  # These overrides apply only to build-vm/build-vm-with-bootloader.
  variant = {
    virtualisation = {
      memorySize = 6144;
      cores = 4;
      diskSize = 32768;
      graphics = false;
      restrictNetwork = true;
      oci-containers.containers = lib.mkForce {};
    };

    # QEMU supplies virtual disks and a modesetting GPU instead of physical NVMe/NVIDIA.
    disko.devices = lib.mkForce {};
    # make-disk-image installs its EFI partition at /boot.
    boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";
    boot.kernelModules = lib.mkForce [];
    # Unlike direct kernel boot, the UEFI path needs explicit serial arguments.
    boot.kernelParams = ["console=tty0" "console=ttyS0,115200"];
    hardware.nvidia.powerManagement.enable = lib.mkForce false;
    services.xserver.screenSection = lib.mkForce "";
    services.btrfs.autoScrub.enable = lib.mkForce false;
    powerManagement.cpuFreqGovernor = lib.mkForce null;
    networking.interfaces = lib.mkForce {eth0.useDHCP = true;};

    # The VM must not require the workstation's host keys or join its private network.
    age.secrets = lib.mkForce {};
    programs.ssh.extraConfig = lib.mkForce "";
    services.tailscale.enable = lib.mkForce false;
    services.tailscale.authKeyFile = lib.mkForce null;

    # Local serial-console access only; no host ports are forwarded.
    users.users.root.initialHashedPassword = lib.mkForce "";
    services.getty.autologinUser = "root";
    services.displayManager.autoLogin = {
      enable = true;
      user = "ag";
    };
  };
in {
  virtualisation.vmVariant = variant;
  virtualisation.vmVariantWithBootLoader = variant;
}
