{...}: {
  vim.telescope = {
    enable = true;

    mappings = {
      findFiles = "<C-p>";
      diagnostics = "<leader>pd";
      liveGrep = "<leader>pg";

      treesitter = "<leader>gt";
      helpTags = "<leader>ga";
    };
  };
}
