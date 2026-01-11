{ ... }:
{
  imports = [ ./fidget.nix ];
  vim.visuals.nvim-web-devicons = {
    enable = true;
  };
  vim = {
    languages = {
      enableTreesitter = true;

      # Languages
      nix.enable = true;
      bash.enable = true;
      svelte.enable = true;

      python.enable = true;
      ts.enable = true;

      rust.enable = true;
      clang = {
        lsp.enable = true;
      };
      csharp = {
        enable = true;
        lsp.server = "omnisharp"; # csharp_ls doesn't seem to work (dll problems)
      };

      css.enable = true;
      html.enable = true;
      sql.enable = true;
      markdown = {
        enable = true;
        extensions.markview-nvim = {
          enable = true;
          setupOpts = {
            preview.icon_provider = "devicons";
          };
        };
      };
    };

    lsp = {
      servers.clangd = {
        enable = true;
        # Use clang from environment
        # this fixes alot of things from using the wrapped clangd,
        # so it will properly find stdlib and deps from compile_commands.json
        cmd = [ "clangd" ];
      };

      enable = true;
      lightbulb.enable = true;

      # Remove all default bindings
      mappings = {
        goToDeclaration = null;
        goToDefinition = null;
        goToType = null;
        listImplementations = null;
        listReferences = null;
        nextDiagnostic = null;
        previousDiagnostic = null;
        openDiagnosticFloat = null;
        documentHighlight = null;
        listDocumentSymbols = null;
        addWorkspaceFolder = null;
        removeWorkspaceFolder = null;
        listWorkspaceFolders = null;
        listWorkspaceSymbols = null;
        hover = null;
        signatureHelp = null;
        renameSymbol = null;
        codeAction = null;
        format = null;
        toggleFormatOnSave = null;
      };
    };

    # Define our own keymaps
    keymaps = [
      {
        key = "ga";
        mode = "n";
        silent = true;
        action = "vim.lsp.buf.code_action";
        lua = true;
        desc = "Code actions";
      }
      {
        key = "K";
        mode = "n";
        silent = true;
        action = "vim.lsp.buf.hover";
        lua = true;
        desc = "Hover";
      }
      # TODO: find keybind
      # {
      #   key = "<C-h>";
      #   mode = "i";
      #   silent = true;
      #   action = "vim.lsp.buf.signature_help";
      #   lua = true;
      #   desc = "Signature help";
      # }
      {
        key = "gd";
        mode = "n";
        silent = true;
        action = "vim.lsp.buf.definition";
        lua = true;
        desc = "Go to definition";
      }
      {
        key = "gh";
        mode = "n";
        silent = true;
        action = ":LspClangdSwitchSourceHeader<CR>";
        desc = "Clangd: Switch Source/Header file";
      }
      {
        key = "gD";
        mode = "n";
        silent = true;
        action = "vim.lsp.buf.declaration";
        lua = true;
        desc = "Go to declaration";
      }
      {
        key = "gR";
        mode = "n";
        silent = true;
        action = "vim.lsp.buf.rename";
        lua = true;
        desc = "Rename symbol";
      }
    ];
  };
}
