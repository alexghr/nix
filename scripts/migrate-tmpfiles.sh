#!/usr/bin/env bash
# One-time migration of Palpatine's Nix-store links from systemd tmpfiles.
# Leave regular files and links outside the old managed paths to Home Manager.
set -euo pipefail
home_dir="${1:?Usage: migrate-tmpfiles.sh HOME_DIRECTORY}"
paths=(
  .bashrc
  .config/i3/config
  .config/i3status/config
  .config/git/config
  .config/tmux/tmux.conf
)
sources=(bashrc i3 i3status gitconfig tmux.conf)
backups=()
for i in "${!paths[@]}"; do
  path="$home_dir/${paths[$i]}"
  [[ -L "$path" ]] || continue
  target=$(readlink "$path")
  case "$target" in
    /nix/store/*-"${sources[$i]}"|/nix/store/*-source/hosts/palpatine/ag/config/"${sources[$i]}")
      backup="$path.before-home-manager"
      if [[ -e "$backup" || -L "$backup" ]]; then
        printf 'Move the existing backup out of the way first: %s\n' "$backup" >&2
        exit 1
      fi
      backups+=("$path")
      ;;
  esac
done
for path in "${backups[@]}"; do
  mv -- "$path" "$path.before-home-manager"
done
