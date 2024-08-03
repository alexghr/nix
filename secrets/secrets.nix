let
  agSshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKiQ7O7hXnhBSma6ge+V8lbDUW74NEq4ixNVTOQtH0H"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELd6/RHyZ3Rw6251R+nWGvkPseaX2yAC2DlZAtRziIt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuq8bF17JoN3KO6t82wUywW3jv/hUeFwRS/USIO7Poh"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRFqPVU7jQOdCVJJKj8+nDs1gLeHhz7+7qptzkI0bta"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
  ];
  hk47HostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaNPaT6E+/26+O9FXE/r9NY733R2qih/HzOlybCuT6k";
  mackeyHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMGuXCcUtBZmwfNVX99zG01uqnaXJFndNwePt3uMGLi";
  implausibleHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdhFymmhJWSlL4if7YjlfVuRiUPjc4r9ddpHcgCzv5v";
  webbyHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyPv3bNmGWZ5kHZOyw2yZZxWRvf3EfiL+cTtrvJ0sNg";
  b1HostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9kPhQAUClUZjG4kQXRg0vxEvDAC5DEmJtLBvVtBnZ1";
  palpatineHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICY7KI54Rb+QmhvYZkUTlGzEPni78VfTBFeUno+h1P9K";
  r5d4HostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNI8tDWbfknVcn3aiU8zdfLdHWECF72fch0voGR8EFe";
in {
  "vader.restic-b2-password.age".publicKeys = agSshKeys;
  "palpatine.tailscale.age".publicKeys = agSshKeys ++ [palpatineHostKey];
  "ag.samba.age".publicKeys = agSshKeys ++ [palpatineHostKey];
  "hk47.tailscale.age".publicKeys = agSshKeys ++ [hk47HostKey];
  "hk47.vader-mac.age".publicKeys = agSshKeys ++ [hk47HostKey r5d4HostKey];
  "ag.npmrc.age".publicKeys = agSshKeys ++ [mackeyHostKey palpatineHostKey];
  "plausible.admin.password.age".publicKeys = agSshKeys ++ [implausibleHostKey b1HostKey];
  "plausible.keybase.age".publicKeys = agSshKeys ++ [implausibleHostKey b1HostKey];
  "webby.ghcr.age".publicKeys = agSshKeys ++ [webbyHostKey b1HostKey];
  "ghcr.age".publicKeys = agSshKeys ++ [b1HostKey];
  "attic.env.age".publicKeys = agSshKeys ++ [b1HostKey];
  "b1.tailscale.age".publicKeys = agSshKeys ++ [b1HostKey];
  "r5d4.tailscale.age".publicKeys = agSshKeys ++ [r5d4HostKey];
}
