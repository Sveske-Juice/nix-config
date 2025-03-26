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
      }
      # Move lines
      {
        key = "J";
        mode = "v";
        silent = true;
        action = ":m '>+1<CR>gv=gv";
      }
      {
        key = "K";
        mode = "v";
        silent = true;
        action = ":m '<-2<CR>gv=gv";
      }
      # Vertical Jumping
      {
        key = "<C-d>";
        mode = "n";
        silent = true;
        action = "<C-d>zz";
      }
      {
        key = "<C-u>";
        mode = "n";
        silent = true;
        action = "<C-u>zz";
      }
      # Clipboard
      {
        key = "<leader>p";
        mode = "x";
        silent = true;
        action = "\"_dP";
      }
      {
        key = "<leader>y";
        mode = "v";
        silent = true;
        action = "\"+y";
      }
      {
        key = "<leader>y";
        mode = "n";
        silent = true;
        action = "\"+Y";
      }
      {
        key = "<leader>d";
        mode = "v";
        silent = true;
        action = "\"_d";
      }
      {
        key = "<leader>d";
        mode = "n";
        silent = true;
        action = "\"_d";
      }
    ];
  };
}
