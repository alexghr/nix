let
  githubSshKeys = import ../lib/github-ssh-keys.nix {};
  agSshKeys = githubSshKeys {
    username = "alexghr";
    sha256 = "sha256-JfAZgyo8CNBmik7qW93OP2yjnRa4XS81hx4kr+wfTTM=";
  };
  vaderHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPNJ1Zg00liAoGjy1wN2OEHLgU2Lcs2zALHh1nGYj9al";
in  {
  "vader.restic-b2-password.age".publicKeys = agSshKeys ++ [vaderHostKey];
}
