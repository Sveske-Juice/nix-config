{ lib, ... }:
{
  vim.binds.whichKey = {
    enable = true;
    setupOpts = {
      notify = true;
      preset = "classic";
    };
  };

  # Until keybinds is correctly implemented we must do this workaround
  # to disable default whichkey registers
  # see: https://github.com/NotAShelf/nvf/issues/746
  vim.binds.whichKey.register = lib.mkForce {
    "<leader>l" = "Telescope";
    "<leader>lg" = "Telescope Git";
  };
}
