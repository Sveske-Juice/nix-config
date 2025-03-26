{
  config,
  pkgs,
  ...
}: {
  vim.keymaps = [
    {
      key = "<leader>f";
      mode = "n";
      silent = true;
      action = ":lua require(\"conform\").format()<CR>";
    }
  ];

  vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      # Use LSP for formatting if no formatter available
      default_format_opts = {
        lsp_format = "fallback";
      };

      formatters_by_ft = {
        lua = ["stylua"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        sh = ["beautysh"];
        cs = ["astyle"];
        java = ["astyle"];
        js = ["prettier"];
        ts = ["prettier"];

        c = ["clang-format"];
        cpp = ["clang-format"];
        h = ["clang-format"];
        hpp = ["clang-format"];

        # Markup languages
        json = ["prettier"];
        yaml = ["prettier"];
        html = ["prettier"];
        css = ["prettier"];
        md = ["prettier"];
        tex = ["tex-fmt"];

        just = ["just"];
        cmake = ["cmake_format"];
      };
      
      # We have to specify the command, otherwise conform
      # doesn't know where to find the formatter executable
      formatters = {
        stylua.command = "${pkgs.stylua}/bin/stylua";
        alejandra.command = "${pkgs.alejandra}/bin/alejandra";
        isort.command = "${pkgs.isort}/bin/isort";
        black.command = "${pkgs.black}/bin/black";
        beautysh.command = "${pkgs.beautysh}/bin/beautysh";
        astyle.command = "${pkgs.astyle}/bin/astyle";
        clang-format.command = "${pkgs.clang-tools}/bin/clang-format";
        prettier.command = "${pkgs.nodePackages.prettier}/bin/prettier";
        tex-fmt.command = "${pkgs.tex-fmt}/bin/tex-fmt";
        just.command = "${pkgs.justbuild}/bin/just";
        cmake_format.command = "${pkgs.cmake-format}/bin/cmake-format";
      };
    };
  };
}
