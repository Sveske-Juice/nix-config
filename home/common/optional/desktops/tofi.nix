{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.tofi.enable = true;

  programs.tofi.settings = {
    width = "35%";
    height = "25%";
    border-width = 1;
    outline-width = 0;
    corner-radius = 4;
    # padding-left = "35%";
    # padding-right = "30%";
    result-spacing = 16;
    num-results = 7;
    prompt-background-padding = 5;
    text-cursor-style = "underscore";
    text-cursor-corner-radius = 1;
    hide-cursor = false;
    text-cursor = true;
    # font-size = lib.mkForce 18;
  };

  home.activation = {
    # https://github.com/philj56/tofi/issues/115#issuecomment-1701748297
    regenerateTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      tofi_cache=${config.xdg.cacheHome}/tofi-drun
      [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
    '';
  };
}
