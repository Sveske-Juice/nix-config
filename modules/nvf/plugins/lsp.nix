{...}: {
  vim = {
    languages = {
      enableLSP = true;
      enableTreesitter = true;

      # Languages
      nix.enable = true;
      bash.enable = true;

      python.enable = true;
      ts.enable = true;

      rust.enable = true;
      clang.enable = true;
      csharp = {
        enable = true;
        lsp.server = "omnisharp"; # csharp_ls doesn't seem to work (dll problems)
      };

      css.enable = true;
      html.enable = true;
      markdown.enable = true;
      sql.enable = true;
    };

    lsp = {
      lightbulb.enable = true;
      lsplines.enable = true;

      mappings = {
        codeAction = "ga";
        documentHighlight = "<leader>gH";
        hover = "K";
        signatureHelp = "<C-h>";

        format = "<leader>lf";
        goToDefinition = "gd";
        goToDeclaration = "gD";
        renameSymbol = "gR";

        listReferences = "gr";
        listDocumentSymbols = "gp";
        listWorkspaceSymbols = "<leader>gp";

        nextDiagnostic = "<leader>lgn";
        previousDiagnostic = "<leader>lgp";
      };
    };
  };
}
