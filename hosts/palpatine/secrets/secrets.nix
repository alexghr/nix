let
  alexghrKeys = import ../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICY7KI54Rb+QmhvYZkUTlGzEPni78VfTBFeUno+h1P9K";
in {
  "tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
  "samba.age".publicKeys = alexghrKeys ++ [hostKey];
}
