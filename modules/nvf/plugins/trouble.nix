{ ... }:
{
  vim.lsp.trouble = {
    enable = true;

    # Disable default mappings
    mappings = {
      workspaceDiagnostics = null;
      documentDiagnostics = null;
      lspReferences = null;
      quickfix = null;
      locList = null;
      symbols = null;
    };
  };
}
