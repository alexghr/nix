let
  alexghrKeys = import ../../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpV8CNp//6m5XzzdxV7p9kTHnQi3hR5Yp9UVPL821CH";
in {
  "tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
  "samba.age".publicKeys = alexghrKeys ++ [hostKey];
}
