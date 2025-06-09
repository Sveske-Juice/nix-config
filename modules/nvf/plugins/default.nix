{ lib, ... }:
{
  imports = [
    ./mini.nix
    ./telescope.nix
    ./dressing.nix
    ./lsp.nix
    ./cmp.nix
    ./conform.nix
    ./lualine.nix
    ./otter.nix
    ./wilder.nix
    ./neoscroll.nix
    ./which-key.nix
    ./zen-mode.nix
    ./todo-comments.nix
    ./trouble.nix
    ./vim-tmux-navigator.nix
  ];
}
