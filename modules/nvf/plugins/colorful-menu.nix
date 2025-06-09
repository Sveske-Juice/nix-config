{ config, pkgs, ... }:
{
  config.vim.lazy.plugins = {
    "colorful-menu.nvim" = {
      package = pkgs.vimPlugins.colorful-menu-nvim;
    };
  };
}
