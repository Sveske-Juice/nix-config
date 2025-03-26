{
  config,
  pkgs,
  ...
}: {
# TODO configure rendering
  config.vim.lazy.plugins = {
    "wilder.nvim" = {
      package = pkgs.vimPlugins.wilder-nvim;
      setupModule = "wilder";
      setupOpts = {
        modes = [":" "/" "?"];
        # next_key = "<C-n>";
        # previous_key = "<C-p>";
        # accept_key = "<CR>";
        # reject_key = "<esc>";
      };
    };
  };
}
