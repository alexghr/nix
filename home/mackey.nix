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
in {
  home.packages = with pkgs; [openssh ghostty-bin gnupg nr];
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
  programs.bash.profileExtra = lib.mkAfter ''
    # fix macOS path_helper putting system binaries first
    export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
    ${builtins.readFile ../dotfiles/bash/mackey-profile}
  '';
  programs.zsh = {
    enable = true;
    initContent = builtins.readFile ../dotfiles/bash/mackey-profile;
  };
}
