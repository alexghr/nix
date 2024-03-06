let
  alexghrKeys = import ../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaNPaT6E+/26+O9FXE/r9NY733R2qih/HzOlybCuT6k";
in {
  "secrets.tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
}
