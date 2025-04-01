{pkgs, ...}: {
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
      action = "<cmd><C-U>TmuxNavigateLeft<CR>";
    }
    {
      key = "<C-j>";
      mode = "n";
      silent = true;
      action = "<cmd><C-U>TmuxNavigateDown<CR>";
    }
    {
      key = "<C-k>";
      mode = "n";
      silent = true;
      action = "<cmd><C-U>TmuxNavigateUp<CR>";
    }
    {
      key = "<C-l>";
      mode = "n";
      silent = true;
      action = "<cmd><C-U>TmuxNavigateRight<CR>";
    }
  ];
}
