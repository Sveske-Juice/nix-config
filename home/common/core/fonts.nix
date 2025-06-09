{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Nerd fonts
    # nerdfonts # loads complete collection, dont want that lol
    nerd-fonts.fira-code
    nerd-fonts.mononoki
  ];
}
