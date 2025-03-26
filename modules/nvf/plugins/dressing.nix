{
  config,
  pkgs,
  ...
}: {
  # Unifys vim.ui* to use telescope etc.
  config.vim.lazy.plugins = {
    "dressing.nvim" = {
      package = pkgs.vimPlugins.dressing-nvim;
    };
  };
}
