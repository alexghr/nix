# add home-manager as a channel first
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

{ config, pkgs, ... }:

let
    # Codex created this script because there's no askpass program for aarch64-darwin in nixpkgs
    # As far as I can tell this is safe: it captures the PIN in a hidden text input and returns it
    # to ssh-agent via stdout (ssh-agent is responsible for creating a secure stdout pipe in this case)
    # the PIN isn't retained in the script's memory (and ssh-agent zeroes it after it unlocks the YubiKey)
    macos-ssh-askpass = pkgs.writeShellScriptBin "ssh-askpass" ''
      exec /usr/bin/osascript - "$1" <<'APPLESCRIPT'
      on run argv
        set response to display dialog (item 1 of argv) ¬
          default answer "" with hidden answer ¬
          buttons {"Cancel", "OK"} default button "OK"
        return text returned of response
      end run
      APPLESCRIPT
    '';
    nr = pkgs.writeShellScriptBin "nr" ''
      set -euo pipefail
      program="$1"
      shift
      exec nix run github:nixos/nixpkgs/nixpkgs-unstable#$program -- $@
    '';
  in

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      trusted-users = ag
    '';
  };

  programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    pinentry_mac
    gnupg
  ];

  environment.shells = [pkgs.bashInteractive];

  home-manager.users.ag = {
    home.packages = [ pkgs.openssh nr ];

    # Run the nixpkgs ssh-agent as a launchd service owned by this user.
    services.ssh-agent = {
      enable = true;
      package = pkgs.openssh;
      socket = "ssh-agent";
    };

    home.sessionVariables = {
      SSH_ASKPASS = "${macos-ssh-askpass}/bin/ssh-askpass";
      SSH_ASKPASS_REQUIRE = "force";
    };

    programs.bash = {
      # macOS may populate SSH_AUTH_SOCK with its bundled agent before Home
      # Manager's shell integration runs. Prefer our agent for local shells,
      # while preserving a forwarded agent in incoming SSH sessions.
      profileExtra = pkgs.lib.mkAfter ''
        if [[ -z "''${SSH_CONNECTION:-}" || -z "''${SSH_AUTH_SOCK:-}" ]]; then
          export SSH_AUTH_SOCK="$(${pkgs.getconf}/bin/getconf DARWIN_USER_TEMP_DIR)/ssh-agent"
        fi
      '';

      bashrcExtra = pkgs.lib.mkAfter ''
        export PATH="/etc/profiles/per-user/$USER/bin:/Users/$USER/.npm/bin:$PATH"
      '';
    };
  };

  age.secrets.ag-npmrc = {
    file = ../../secrets/ag.npmrc.age;
    owner = "ag";
    group = "staff";
  };
}
