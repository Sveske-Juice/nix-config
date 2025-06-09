{ pkgs, ... }:
{
  config.vim.lazy.plugins = {
    "vim-tmux-navigator" = {
      package = pkgs.vimPlugins.vim-tmux-navigator;
    };
  };

  config.vim.keymaps = [
    {
      key = "<C-h>";
      mode = "n";
      silent = true;
      action = "<cmd>TmuxNavigateLeft<CR>";
    }
    {
      key = "<C-j>";
      mode = "n";
      silent = true;
      action = "<cmd>TmuxNavigateDown<CR>";
    }
    {
      key = "<C-k>";
      mode = "n";
      silent = true;
      action = "<cmd>TmuxNavigateUp<CR>";
    }
    {
      key = "<C-l>";
      mode = "n";
      silent = true;
      action = "<cmd>TmuxNavigateRight<CR>";
    }
  ];
}
