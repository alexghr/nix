let
  alexghrKeys = import ../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyf9c+3WI1bIG0w1o83UCSE4lbhpUEqahjZUPTJKgoL";
in {
  "secrets.tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
  "secrets.uptimerobot.age".publicKeys = alexghrKeys ++ [hostKey];
}