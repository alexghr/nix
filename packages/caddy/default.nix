{...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    buildCaddy = import ./build-caddy.nix;
  in {
    packages.caddy = pkgs.callPackage buildCaddy {};
    packages.caddyCF = pkgs.callPackage buildCaddy {
      externalPlugins = [
        {
          name = "caddy-dns/cloudflare";
          repo = "github.com/caddy-dns/cloudflare";
          version = "2fa0c8ac916ab13ee14c836e59fec9d85857e429";
        }
      ];
      vendorHash = "sha256-gL1x0Bv02H5uCcM7IOQ8507sT3jn+5gnsnKyUfcD9ac=";
    };
  };
}
