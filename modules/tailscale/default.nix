{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.alexghr.tailscale;
in {
  options.alexghr.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
    authKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the tailscale authentication key";
    };
    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to advertise this host as an exit node";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures =
        if cfg.exitNode
        then "both"
        else "client";
    };

    # taken from https://tailscale.com/blog/nixos-minecraft/
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up \
          --auth-key file:${cfg.authKeyFile} \
          ${lib.optionalString cfg.exitNode "--advertise-exit-node"}
      '';
    };
  };
}
