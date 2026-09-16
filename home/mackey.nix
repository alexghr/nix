{
  config,
  pkgs,
  lib,
  ...
}: let
  wakePalpatine = pkgs.writeShellApplication {
    name = "wake-palpatine";
    runtimeInputs = [pkgs.openssh];
    text = ''
      exec ssh -o ConnectTimeout=10 trip \
        'wakeonlan 30:52:5a:00:36:5e'
    '';
  };
  askpass = pkgs.writeShellScriptBin "ssh-askpass" ''
    # OpenSSH uses this hint for informational prompts that need no response.
    if [ "''${SSH_ASKPASS_PROMPT:-}" = "none" ]; then
      exec /usr/bin/osascript - "$1" <<'APPLESCRIPT'
    on run argv
      display notification (item 1 of argv) with title "SSH: Touch your YubiKey"
    end run
    APPLESCRIPT
    fi

    exec /usr/bin/osascript - "$1" <<'APPLESCRIPT'
    on run argv
      set response to display dialog (item 1 of argv) ¬
        default answer "" with hidden answer ¬
        buttons {"Cancel", "OK"} default button "OK"
      return text returned of response
    end run
    APPLESCRIPT
  '';
  askpassEnvironment = {
    SSH_ASKPASS = "${askpass}/bin/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "force";
  };
  loadSshKeys = pkgs.writeShellScript "ssh-add-keys" ''
    export SSH_AUTH_SOCK="$(${pkgs.getconf}/bin/getconf DARWIN_USER_TEMP_DIR)/${config.services.ssh-agent.socket}"

    # launchd starts the loader and agent independently; wait for the agent.
    for attempt in {1..60}; do
      ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
      status=$?
      if [ "$status" -eq 0 ] || [ "$status" -eq 1 ]; then
        exec ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_ed25519_sk" "$HOME/.ssh/git-signing"
      fi
      ${pkgs.coreutils}/bin/sleep 0.5
    done

    echo "SSH agent did not become available for key loading" >&2
    exit 1
  '';
in {
  home.packages = with pkgs; [ghostty-bin wakePalpatine];
  targets.darwin.defaults."org.gpgtools.pinentry-mac".UseKeychain = true;
  services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
  home.sessionVariables = askpassEnvironment;
  # launchd agents do not inherit the shell's session variables.
  launchd.agents.ssh-agent.config.EnvironmentVariables = askpassEnvironment;
  launchd.agents.ssh-add-keys = {
    enable = true;
    config = {
      ProgramArguments = ["${loadSshKeys}"];
      EnvironmentVariables = askpassEnvironment;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
      RunAtLoad = true;
    };
  };
  home.sessionPath = ["$HOME/.npm/bin" "$HOME/.npm-packages/bin" "$HOME/.corepack"];
  programs.bash.profileExtra = lib.mkAfter ''
    # fix macOS path_helper putting system binaries first
    export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
    ${builtins.readFile ../dotfiles/bash/mackey-profile}
  '';
}
