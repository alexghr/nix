{ pkgs, ... }:

{
  # I want to have these packages available on all hosts
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    pciutils
    usbutils
    dnsutils
    lsof
    tree
    parted
    unzip
    ripgrep
    bat
    jq
    bc
    gcc
    gnumake
    automake
    autoconf
    compsize
    neofetch
  ];
}
