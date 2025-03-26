{...}: {
  vim.options = {
    relativenumber = true;
    nu = true;

    # set by .editorconfig hopefully...
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
