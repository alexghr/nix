let
  alexghrKeys = import ../../../alexghr.keys.nix;
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBH453UsbFnTBxcfLeOicu38OBHwwa7eAI0zNyFR6jg";
in {
  "tailscale.age".publicKeys = alexghrKeys ++ [hostKey];
  "samba.age".publicKeys = alexghrKeys ++ [hostKey];
}
