{ pkgs, ... }:

{
  # I want to have these packages available on all hosts
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    tree
    unzip
    ripgrep
    bat
    jq
    bc
    gnumake
    automake
    autoconf
    neofetch
    python3
  ] ++ (if pkgs.stdenv.isLinux then [
    dnsutils
    lsof
    pciutils
    usbutils
    parted
    compsize
    gcc
  ] else []);
}
