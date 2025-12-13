{...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    # adapted from https://github.com/fpletz/flake/blob/5a8547849ec5ba64c1d08f2af27e39628f3ee5a6/pkgs/by-name/helium-browser.nix
    helium = {
      stdenv,
      lib,
      appimageTools,
      fetchurl,
      makeDesktopItem,
      copyDesktopItems,
    }:
    let
      pname = "helium-browser";
      version = "0.5.6.1";
    
      architectures = {
        "x86_64-linux" = {
          arch = "x86_64";
          hash = "sha256-J1hTquA47gim0H7TFMM+JabY5YRcL5snJTpM/elN1zI=";
        };
        "aarch64-linux" = {
          arch = "arm64";
          hash = "";
        };
      };
    
      src =
        let
          inherit (architectures.${stdenv.hostPlatform.system}) arch hash;
        in
        fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${arch}.AppImage";
          inherit hash;
        };
    in
    appimageTools.wrapType2 {
      inherit pname version src;
      nativeBuildInputs = [ copyDesktopItems ];
      desktopItems = [
        (makeDesktopItem {
    
        })
      ];
      meta = {
        platforms = lib.attrNames architectures;
      };
    };
  in {
    packages.helium = pkgs.callPackage helium {};
  };
}
