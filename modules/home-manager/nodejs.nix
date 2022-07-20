{ config, pkgs, lib, ...}:
with lib; {
  options.alexghr = {
    nodejs = mkOption {
      description = "Enable NodeJS using home-manager";
      default = {};

      type = types.attrsOf (types.submodule ({ config, name, ...}: {
        options = {
          package = mkOption {
            type = types.package;
            default = pkgs.nodejs-16_x;
            defaultText = "pkgs.nodejs-16_x";
            description = "The NodeJS package to use";
          };

          npmrc = mkOption {
            type = types.nullOr types.path;
            description = "Path to user .npmrc";
            default = null;
          };
        };
      }));
    };
  };

  config = {
    home-manager.users = mapAttrs (name: nodeConfig: hm: {
      home.packages = [nodeConfig.package];
      home.file = mkIf (nodeConfig.npmrc != null) {
        ".npmrc" = {
          source = hm.config.lib.file.mkOutOfStoreSymlink nodeConfig.npmrc;
        };
      };
    }) config.alexghr.nodejs;
  };
}
