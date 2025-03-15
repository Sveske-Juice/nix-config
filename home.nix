{username ? throw "no username provided"}: {pkgs, ...}: {
    imports = [];

    home.username = username;
    home.homeDirectory = "/home/${username}";

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
        dig
    ];

    home.sessionVariables = {
        EDITOR = "vim";
    };

    home.stateVersion = "24.11";
}
