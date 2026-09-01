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
    openssh
    macos-ssh-askpass
  ];

  environment.shells = [pkgs.bashInteractive];

  home-manager.users.ag.programs.bash.bashrcExtra = pkgs.lib.mkAfter ''
    export PATH="/etc/profiles/per-user/$USER/bin:/Users/$USER/.npm/bin:$PATH"
    export SSH_ASKPASS="${macos-ssh-askpass}/bin/ssh-askpass";
    export SSH_ASKPASS_REQUIRE=force
  '';

  age.secrets.ag-npmrc = {
    file = ../../secrets/ag.npmrc.age;
    owner = "ag";
    group = "staff";
  };
}
