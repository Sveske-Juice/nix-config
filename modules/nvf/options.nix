{ ... }:
{
  vim.options = {
    termguicolors = true;
    relativenumber = true;
    nu = true;

    # set by .editorconfig hopefully...
    # TODO: fallback to 4 if no editorconfig overiddes

    # tabstop = 4;
    # softtabstop = 4;
    # shiftwidth = 4;
    # expandtab = true;

    scrolloff = 8;

    updatetime = 50;
    colorcolumn = "100";
    wrap = false;

    hlsearch = false;
    incsearch = true;
  };
}
