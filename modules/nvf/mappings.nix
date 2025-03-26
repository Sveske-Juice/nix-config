{...}: {
  vim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        key = "<leader>pv";
        mode = "n";
        silent = true;
        action = ":Ex<CR>";
        desc = "Show File Explorer";
      }
      # Move lines
      {
        key = "J";
        mode = "v";
        silent = true;
        action = ":m '>+1<CR>gv=gv";
        desc = "Move line down";
      }
      {
        key = "K";
        mode = "v";
        silent = true;
        action = ":m '<-2<CR>gv=gv";
        desc = "Move line up";
      }
      # Clipboard
      {
        key = "<leader>p";
        mode = "n";
        silent = true;
        action = "\"_dP";
        desc = "Paste to void register";
      }
      {
        key = "<leader>p";
        mode = "x";
        silent = true;
        action = "\"_dP";
        desc = "Paste to void register";
      }
      {
        key = "<leader>y";
        mode = "v";
        silent = true;
        action = "\"+y";
        desc = "Yank to system clipboard";
      }
      {
        key = "<leader>y";
        mode = "n";
        silent = true;
        action = "\"+Y";
        desc = "Yank to system clipboard";
      }
      {
        key = "<leader>d";
        mode = "v";
        silent = true;
        action = "\"_d";
        desc = "Delete to void register";
      }
      {
        key = "<leader>d";
        mode = "n";
        silent = true;
        action = "\"_d";
        desc = "Delete to void register";
      }
    ];
  };
}
