{ config, pkgs, ... }:
{
  config.vim.lazy.plugins = {
    "neoscroll.nvim" = {
      package = pkgs.vimPlugins.neoscroll-nvim;
      setupModule = "neoscroll";
      setupOpts = {
        duration_multiplier = "0.3";
      };
    };
  };
}
