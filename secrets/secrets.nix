let
   agSshKeys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKiQ7O7hXnhBSma6ge+V8lbDUW74NEq4ixNVTOQtH0H"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELd6/RHyZ3Rw6251R+nWGvkPseaX2yAC2DlZAtRziIt"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCcOm5bv/HZtyaavJ0xBFvZJ6fLfuUxhtFj1UU7YXfi"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuq8bF17JoN3KO6t82wUywW3jv/hUeFwRS/USIO7Poh"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRFqPVU7jQOdCVJJKj8+nDs1gLeHhz7+7qptzkI0bta"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcqnrGwHDkQPUcSOZnLEd7Y7kMxaiTkIL0uz/P2YDaV"
   ];
  vaderHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPNJ1Zg00liAoGjy1wN2OEHLgU2Lcs2zALHh1nGYj9al";
  hk47HostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaNPaT6E+/26+O9FXE/r9NY733R2qih/HzOlybCuT6k";
  mackeyHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMGuXCcUtBZmwfNVX99zG01uqnaXJFndNwePt3uMGLi";
  implausibleHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdhFymmhJWSlL4if7YjlfVuRiUPjc4r9ddpHcgCzv5v";
  webbyHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyPv3bNmGWZ5kHZOyw2yZZxWRvf3EfiL+cTtrvJ0sNg";
  b1HostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9kPhQAUClUZjG4kQXRg0vxEvDAC5DEmJtLBvVtBnZ1";
in  {
  "vader.restic-b2-password.age".publicKeys = agSshKeys ++ [vaderHostKey];
  "vader.tailscale.age".publicKeys = agSshKeys ++ [vaderHostKey];
  "hk47.tailscale.age".publicKeys = agSshKeys ++ [hk47HostKey];
  "hk47.vader-mac.age".publicKeys = agSshKeys ++ [hk47HostKey];
  "ag.npmrc.age".publicKeys = agSshKeys ++ [vaderHostKey mackeyHostKey];
  "vader.ghcr.age".publicKeys = agSshKeys ++ [vaderHostKey];
  "plausible.releaseCookie.age".publicKeys = agSshKeys ++ [implausibleHostKey b1HostKey];
  "plausible.admin.password.age".publicKeys = agSshKeys ++ [implausibleHostKey b1HostKey];
  "plausible.keybase.age".publicKeys = agSshKeys ++ [implausibleHostKey b1HostKey];
  "webby.ghcr.age".publicKeys = agSshKeys ++ [webbyHostKey b1HostKey];
  "ghcr.age".publicKeys = agSshKeys ++ [b1HostKey];
  "attic.env.age".publicKeys = agSshKeys ++ [b1HostKey];
  "b1.tailscale.age".publicKeys = agSshKeys ++ [b1HostKey];
}
