{
  pkgs,
  lib,
  ...
}: let
  askpass = pkgs.writeShellScriptBin "ssh-askpass" ''
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
    program="''${1:?Usage: nr PACKAGE [ARGUMENTS...]}"
    shift
    exec nix run "github:nixos/nixpkgs/nixpkgs-unstable#$program" -- "$@"
  '';
in {
  home.packages = with pkgs; [openssh kubectl kubeseal ngrok vscode ghostty-bin gnupg nr unstable.neovim];
  services.ssh-agent = {
    enable = true;
    package = pkgs.openssh;
    socket = "ssh-agent";
  };
  home.sessionVariables = {
    SSH_ASKPASS = "${askpass}/bin/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "force";
  };
  home.sessionPath = ["$HOME/.npm/bin" "$HOME/.npm-packages/bin" "$HOME/.corepack"];
  programs.bash.profileExtra = lib.mkAfter (builtins.readFile ../dotfiles/bash/mackey-profile);
  programs.zsh = {
    enable = true;
    initContent = builtins.readFile ../dotfiles/bash/mackey-profile;
  };
}
