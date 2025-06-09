{ config, pkgs, ... }:
{
  config.vim = {
    lazy.plugins = {
      "zen-mode.nvim" = {
        package = pkgs.vimPlugins.zen-mode-nvim;
        setupModule = "zen-mode";
        setupOpts = {
          plugins = {
            tmux.enabled = true; # Hide tmux status line
            todo.enabled = true; # Hide todo highlights (todo-comments.nvim)
          };
        };
      };
    };
    keymaps = [
      {
        key = "<leader>z";
        mode = "n";
        silent = true;
        action = ":ZenMode<CR>";
        desc = "Toggle zen-mode";
      }
    ];
  };
}
