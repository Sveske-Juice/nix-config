{ pkgs, ... }:
{
  config.vim.lazy.plugins."smartyank.nvim" = {
    package = pkgs.vimPlugins.smartyank-nvim;
    setupModule = "smartyank";
    setupOpts.osc52.ssh_only = false;
  };
}
