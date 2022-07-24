{
  pkgs ? import <nixpkgs>,
  ...
}: pkgs.stdenv.mkDerivation rec {
  pname = "pnpm";
  version = "7.5.2";
  buildInputs = [
    pkgs.nodejs-18_x
  ];

  buildPhase = ''
    corepack prepare pnpm@${version} -o
  '';

  installPhase = ''
    tar xf corepack.tgz
    mv pnpm/${version}/* $out/
  '';
}
