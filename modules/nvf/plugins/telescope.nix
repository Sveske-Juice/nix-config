{pkgs, ...}: {
  vim.telescope = {
    enable = true;

    # wait for https://github.com/NotAShelf/nvf/issues/746
    mappings = {
      findFiles = null;
      liveGrep = null;
      buffers = null;
      helpTags = null;
      open = null;
      resume = null;

      gitCommits = null;
      gitBufferCommits = null;
      gitBranches = null;
      gitStatus = null;
      gitStash = null;

      lspDocumentSymbols = null;
      lspWorkspaceSymbols = null;
      lspReferences = null;
      lspImplementations = null;
      lspDefinitions = null;
      lspTypeDefinitions = null;
      diagnostics = null;

      treesitter = null;
      findProjects = null;
    };

    setupOpts = {
      defaults = {
        path_display = ["smart"];
        pickers.find_command = ["${pkgs.fzf}/bin/fzf"];
      };
    };
  };

  vim.binds.whichKey.register = {
    "<leader>l" = "Telescope";
    "<leader>lg" = "Telescope Git";
  };

  vim.keymaps = [
    {
      key = "<C-p>";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope find_files<CR>";
      desc = "Find files";
    }
    {
      key = "<leader>lf";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope live_grep<CR>";
      desc = "Live Grep";
    }
    {
      key = "<leader>lgc";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope git_commits<CR>";
      desc = "Git Commits";
    }
    {
      key = "<leader>lgb";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope git_branches<CR>";
      desc = "Git Branches";
    }
    {
      key = "<leader>lgs";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope git_status<CR>";
      desc = "Git Status";
    }
    {
      key = "<leader>lp";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope lsp_document_symbols<CR>";
      desc = "LSP Document Symbols";
    }
    {
      key = "<leader>lP";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope lsp_workspace_symbols<CR>";
      desc = "LSP Workspace Symbols";
    }
    {
      key = "<leader>lr";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope lsp_references<CR>";
      desc = "LSP References";
    }
    {
      key = "<leader>ld";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope diagnostics<CR>";
      desc = "Diagnostics";
    }
    {
      key = "<leader>lt";
      mode = "n";
      silent = true;
      action = "<cmd>Telescope treesitter<CR>";
      desc = "Treesitter";
    }
 ];
}
