{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "float, class:steam"
      "center, class:steam, title:Steam"
      "opacity 1 1, class:steam"
      "size 1100 700, class:steam, title:Steam"
      "size 460 800, class:steam, title:Friends List"
      "idleinhibit fullscreen, class:steam"
    ];
  };
}
