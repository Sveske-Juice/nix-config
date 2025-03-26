{...}:
{
  vim.notes.todo-comments = {
    enable = true;
    setupOpts = {
      signs = true;
      highlight = {
        multiline = true;
        multiline_pattern = "^.";
        multiline_context = 10;
        before = "";
        keyword = "wide";
        after = "fg";
      };
      keywords = {
        FIX = {
          icon = " ";
          color = "error";
          alt = [ "FIXME" "BUG" "FIXIT" "ISSUE" ];
        };
        TODO = {
          icon = " ";
          color = "info";
        };
        HACK = {
          icon = " ";
          color = "warning";
          alt = ["GARBAGE" "SHIT" "DISGUSTING"];
        };
        WARN = {
          icon = " ";
          color = "warning";
          alt = ["WARNING" "XXX" "BRACEYOURSELF"];
        };
        PERF = {
          icon = " ";
          alt = ["OPTIM" "OPTIMIZE" "PERFORMANCE"];
        };
        NOTE = {
          icon = " ";
          color = "hint";
          alt = ["INFO" "INFORMATION"];
        };
        TEST = {
          icon = "⏲ ";
          color = "test";
          alt = ["TESTING" "PASSED" "PASS" "FAILED" "FAIL"];
        };
      };
    };
    
    # Disable default mappings
    mappings = {
      quickFix = null;
      telescope = null;
      trouble = null;
    };
  };

  vim.keymaps = [
    {
      key = "<leader>t";
      mode = "n";
      silent = true;
      action = ":TodoTelescope<CR>";
      desc = "Open Todo's in Telescope";
    }
  ];
}
