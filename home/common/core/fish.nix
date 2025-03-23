{pkgs, ...}: {
  home.packages = [
    pkgs.oh-my-fish # dep for plugins
  ];

  programs.fish = {
    enable = true;
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
