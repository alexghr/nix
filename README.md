# Nix configuration

This repo contains the Nix configuration for the various machines I use. I'm
new to Nix/NixOS and its ecosystem so a lot of the code you'll see here might
not be its best.

## Flakes

When I first started using NixOS I used the standard configuration at
`/etc/nixos/configuration.nix`. This worked well for me while I was managing
only one machine. As I installed Nix on more and more machines I wanted a more
elegant way to manage shared configuration. So I arrived at Flakes.

This repo is a mix of Flakes and non-Flakes configuration, but most of the
hosts I use daily have been converted to Flakes.

For an intro to flakes I recommend the [original Tweag Flakes intro] on using
Nix Flakes to manage a NixOS system.

For other example configs on Github, have a look at this list I made
[nix-configs].

## Btrfs & backups

In before people get triggered, I use Btrfs on all of my machines (including
a raspi's SDCard). It's great 👌

To prevent sadness in case something goes wrong in the future I back up daily
to Backblaze. See my custom [restic module] for that

## Hosts

The [./hosts] directory contains the configuration files for my machines.
I name all of my machines after Star Trek* characters.

Multiple configurations could be applied to the same machine. That's because
I dual boot sometimes.

Current computers:

- 🖥️ [vader] - Main NixOS install
- 💻 [ishuttle] - A macbook running [nix-darwin] & [home-manager]
- <img alt="raspi" src="./.github/img/raspi.png" style="height:1.5em;vertical-align:middle"/> [hk47] -
  A Raspberry Pi 4B in my closet. Mainly runs the Unifi controller
- 🖥️ [nix-1] - A Hetzner VPS. Runs k3s
- 💀 [stormtrooper] - First time I installed Nix on WSL. Mostly to experiment.
  Preceded [nixtrooper]
- 💀 [wsltrooper] - Second time I installed Nix on WSL to test Flakes
- 💀 [nixtrooper] - First NixOS install on bare metal. Preceded [vader]

*😝

## System management

Most of the time it boils down to this:

- make a change in this repo (e.g. add a new package, add a new env var)
- execute

  ```shell
  $ sudo nixos-rebuild switch --flake /path/to/git/repo
  ```

  alternatively, you can push the change to Github and run

  ```shell
  $ sudo nixos-rebuild switch --flake github:alexghr/nix
  ```

`nixos-rebuild` will default to apply the `nixosConfiguration` named after the
current system's hostname, so the above command is equivalent to

```shell
$ sudo nixos-rebuild switch --flake github:alexghr/nix#$(hostname)
```

## Todo

- [ ] remove stale hosts
- [ ] migrate other machines to Flakes
- [ ] setup CI (update flakes, push derivations to cachix, etc)

[original Tweag Flakes intro]: https://www.tweag.io/blog/2020-07-31-nixos-flakes/
[nix-configs]: https://github.com/stars/alexghr/lists/nix-configs
[restic module]: ./modules/restic/default.nix
[./hosts]: ./hosts
[vader]: ./hosts/vader/configuration.nix
[ishuttle]: ./hosts/ishuttle/darwin-configuration.nix
[hk47]: ./hosts/hk47/configuration.nix
[nix-1]: ./hosts/nix-1/configuration.nix
[stormtrooper]: ./hosts/stormtrooper
[wsltrooper]: ./hosts/wsltrooper
[nixtrooper]: ./hosts/nixtrooper/etc/nixos/configuration.nix
[nix-darmin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager
