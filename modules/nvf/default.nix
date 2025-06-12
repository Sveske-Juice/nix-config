{ lib, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./mappings.nix

    ./plugins
  ];

  vim.theme.enable = false;
  vim.theme.name = "tokyonight";
  vim.theme.style = "storm";

  vim.theme.transparent = true;
  vim.startPlugins = [ pkgs.vimPlugins.lackluster-nvim ];
  vim.luaConfigRC.theme = lib.nvim.dag.entryBefore [ "pluginConfigs" "lazyConfigs" ] ''
    local lackluster = require("lackluster");
    lackluster.setup({
      tweak_background = {
        normal = 'none',
        telescope = 'none',
        menu = lackluster.color.gray3,
        popup = 'default',
      },
    });
    vim.cmd("colorscheme lackluster");
  '';
}
