{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.regreet = {
    enable = true;
    settings = {
      /*
        gtk = {
            application_prefer_dark_theme = "true";
        };
      */
      appearance = {
        greeting_msg = "Helloo World!";
      };
    };
  };
}
