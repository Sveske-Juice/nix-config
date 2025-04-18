# This file will be included in EVERY user's home manager configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../../modules/common/host-spec.nix

    ./fish.nix
    ./fonts.nix
  ];

  # Our required packages that I expect on every system
  home.packages = with pkgs; [
    wget
    curl
    git
    btop
    eza
    fzf
    fastfetch
    vim
    killall
    unzip
    tmux
    tcpdump
    netcat-gnu
    dig
  ];
}
