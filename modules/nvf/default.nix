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

  # vim.theme.transparent = true;
  vim.startPlugins = [ pkgs.vimPlugins.lackluster-nvim ];
  vim.luaConfigRC.theme = lib.nvim.dag.entryBefore [ "pluginConfigs" "lazyConfigs" ] ''
    require("lackluster").setup({
    });
    vim.cmd("colorscheme lackluster");
  '';
}
