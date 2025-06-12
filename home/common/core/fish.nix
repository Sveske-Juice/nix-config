{ pkgs, ... }:
{
  home.packages = [
    pkgs.oh-my-fish # dep for plugins
  ];

  programs.fish = {
    enable = true;
    shellAbbrs = {
      "nrb" = "sudo nixos-rebuild switch --flake /etc/nixos";

      "gp" = "git push";
      "gu" = "git pull";
      "gc" = "git commit -m";
      "ga" = "git add";
      "gs" = "git status";
    };

    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
  };
}
