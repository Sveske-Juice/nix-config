{...}: {
  imports = [
    ./options.nix
    ./mappings.nix

    ./plugins
  ];

  vim.theme.enable = true;
  vim.theme.name = "gruvbox";
  vim.theme.style = "dark";
}
