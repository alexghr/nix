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
      "emSign ECC Root CA - G3"
      "emSign Root CA - C1"
      "emSign ECC Root CA - C3"
    ];
  };
}
