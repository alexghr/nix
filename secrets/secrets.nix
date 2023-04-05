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
  mackeyHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMGuXCcUtBZmwfNVX99zG01uqnaXJFndNwePt3uMGLi";

in  {
  "vader.restic-b2-password.age".publicKeys = agSshKeys ++ [vaderHostKey];
  "vader.tailscale.age".publicKeys = agSshKeys ++ [vaderHostKey];
  "ag.npmrc.age".publicKeys = agSshKeys ++ [vaderHostKey mackeyHostKey];
  "vader.ghcr.age".publicKeys = agSshKeys ++ [vaderHostKey];
}
