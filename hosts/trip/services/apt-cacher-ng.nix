{
  config,
  pkgs,
  ...
}: let
  port = 3142;
  acngConf = pkgs.writeTextDir "acng.conf" ''
    PidFile: /var/run/apt-cacher-ng/pid
    CacheDir: /var/cache/apt-cacher-ng
    LogDir: /var/log/apt-cacher-ng
    VerboseLog: 1
    Port: ${toString port}
    BindAddress: 0.0.0.0
    ReportPage: acng-report.html
    ForeGround: 1

    Remap-debrep: file:deb_mirror*.gz /debian ; file:backends_debian # Debian Archives
    Remap-debsec: security.debian.org

    Remap-uburep: file:ubuntu_mirrors /ubuntu ; file:backends_ubuntu # Ubuntu Archives
    Remap-ubusec: security.ubunutu.com

    ForceManaged: 0
    ExTreshold: 4

    PassThroughPattern: .*
  '';
in {
  services.blocky.settings.customDNS.mapping."aptcache.esrever.uno" = "10.1.1.110";
  networking.firewall.allowedTCPPorts = [port];

  systemd.services.apt-cacher-ng = {
    description = "APT mirror";
    path = [pkgs.apt-cacher-ng];
    script = ''
      apt-cacher-ng -c ${acngConf}
    '';
    wantedBy = ["multi-user.target"];
    restartTriggers = [acngConf];
    stopIfChanged = true;
  };
}
