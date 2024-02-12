let
  alexghrKeys = import ../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNI8tDWbfknVcn3aiU8zdfLdHWECF72fch0voGR8EFe";
in {
  "secrets.tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
}
