let
  alexghrKeys = import ../../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyf9c+3WI1bIG0w1o83UCSE4lbhpUEqahjZUPTJKgoL";
in {
  "tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
  "uptimerobot.age".publicKeys = alexghrKeys ++ [hostKey];
  "caddy.age".publicKeys = alexghrKeys ++ [hostKey];
  "ghcr.age".publicKeys = alexghrKeys ++ [hostKey];
  "cloudflared.age".publicKeys = alexghrKeys ++ [hostKey];
}
