{
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.ca = {...}: {
    security.pki.caCertificateBlacklist = [
      # https://github.com/NixOS/nixpkgs/pull/576390/changes
      "Comodo AAA Services root"
    ];
  };
}
