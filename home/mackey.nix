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
  home.packages = with pkgs; [openssh ghostty-bin];
  targets.darwin.defaults."org.gpgtools.pinentry-mac".UseKeychain = true;
  services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
  programs.ssh.settings.alexg-box.RemoteForward = "/run/user/30038/gnupg/S.gpg-agent.fwd /Users/ag/.gnupg/S.gpg-agent.extra";
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
}
