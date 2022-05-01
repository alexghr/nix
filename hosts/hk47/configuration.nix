# configuration

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./wm.nix
    ];

  boot = {
    kernelParams = ["cma-256M"];
    #kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi = {
        enable = true;
        version = 4;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=256
        '';
      };
    };
    
    # custom /tmp in filesystems
    # I needed more storage in order for nix to be able to build things
    # default tmpOnTmpfs allocates 50% of RAM, which is 2GiB on this system
    tmpOnTmpfs = false;

    #initrd.postDeviceCommands = pkgs.lib.mkBefore ''
      #mkdir -p /mnt
      #mount -o subvol=/ /dev/mmcblk0p2 /mnt
      #btrfs subvolume list -o /mnt/root |
        #cut -f9 -d' ' |
        #while read subvolume; do
          #echo "deleting /$subvolume subvolume"
          #btrfs subvolume delete "/mnt/$subvolume"
        #done &&
     #echo "deleting /root subvolume" &&
     #btrfs subvolume delete /mnt/root

     #echo "restoring /root from blank"
     #btrfs subvolume snapshot /mnt/root-blank /mnt/root
#
     #umount /mnt
    #'';
  };


  time.timeZone = "Europe/London";

  networking = {
    useDHCP = false;
    hostName = "hk47";
    networkmanager.enable = false;
    wireless = {
      enable = false;
      interfaces = ["wlan0"];
    };

    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    firewall.enable = true;
    firewall.allowedTCPPorts = [
      8080 # unifi http port
      8443 # unifi https port
    ];
  };

  nixpkgs.config.allowUnfree = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users = {
    mutableUsers = true;
    users.ag = {
      # don't forget to set a password
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    groups.uinfi = {};

    #users.unifi = {
    #  #uid = config.ids.uids.unifi;
    #  isSystemUser = true;
    #  group = "unifi";
    #  description = "UniFi controller daemon user";
    #  home = "/var/lib/unifi";
    #};
  };

  environment.systemPackages = with pkgs; [
    vim
    raspberrypi-eeprom
    libraspberrypi
    glxinfo
    #glxgears
    mesa-demos
  ];

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi6;
    openPorts = true;
  };
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?


  #systemd.tmpfiles.rules = [
    #"L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    #"L /var/lib/unifi/data - - - - /persist/var/lib/unifi/data"
    #"L /root/.nix-channels - - - - /persist/root/.nix-channels"
    # I think this will save me having to nix-channel --update every boot
    #"L /root/.cache - - - - /persist/root/.cache"
  #];

  services.openssh = {
    enable = true;
    #hostKeys = [
      #{ path = "/persist/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
      #{ path = "/persist/etc/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
    #];
  };

  environment.etc = {
    #nixos.source = "/persist/etc/nixos";
    #NIXOS.source = "/persist/etc/NIXOS";
    #machine-id.source = "/persist/etc/machine-id";
    
    # using mutableUsers = false, so back these up
    #passwd.source = "/persist/etc/passwd";
    #shadow.source = "/persist/etc/shadow";
    #group.source = "/persist/etc/group";
  };

  #virtualisation.podman = {
    #enable = true;
    #dockerCompat = true;
  #};

  #virtualisation.oci-containers = {
    #backend = "podman";
    #containers = {
      #unifi = {
        #image = "lscr.io/linuxserver/unifi-controller";
        #ports = [
          #"0.0.0.0:8443:8443"
          #"0.0.0.0:3478:3478/udp"
          #"0.0.0.0:10001:10001/udp"
          #"0.0.0.0:8080:8080"
          #"0.0.0.0:1900:1900/udp"
          #"0.0.0.0:8843:8843"
          #"0.0.0.0:8880:8880"
          #"0.0.0.0:6789:6789"
          #"0.0.0.0:5514:5514/udp"
        #];
        #volumes = ["/var/unifi/config:/config"];
      #};
    #};
  #};
}

