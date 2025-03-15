{
    config,
    lib,
    pkgs,
    ...
}:
{
    home.packages = with pkgs; [
        wget
        curl
        git
        btop
        eza
        fzf
        fastfetch
    ];
}
