{
  lib,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = lib.mkForce 0.8;
    };
  };

  home.sessionVariables = {
    TERM = "alacritty";
  };
}
