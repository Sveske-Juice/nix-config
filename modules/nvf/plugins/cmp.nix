{lib, pkgs, ...}: {
  imports = [
    ./colorful-menu.nix # Uses treesitter for highlighting completion menu
  ];
  vim.autocomplete.blink-cmp = {
    enable = true;

    # mappings = {
    #   close = "<esc>";
    #   complete = "<C-Space>"; # I never use this
    #   confirm = "<CR>";
    #
    #   next = "<C-n>";
    #   previous = "<C-p>";
    #
    #   scrollDocsDown = "<C-d>";
    #   scrollDocsUp = "<C-u>";
    # };
    sourcePlugins.lsp = {
      enable = true;
      package = pkgs.vimPlugins.blink-cmp;
      module = "blink.cmp.sources.lsp";
    };
    sourcePlugins.buffer = {
      enable = true;
      package = pkgs.vimPlugins.blink-cmp;
      module = "blink.cmp.sources.buffer";
    };
    sourcePlugins.path = {
      enable = true;
      package = pkgs.vimPlugins.blink-cmp;
      module = "blink.cmp.sources.path";
    };
    sourcePlugins.emoji.enable = true;

    setupOpts = {
      signature.enabled = true;

      completion.ghost_text.enabled = true;
      sources.default = [
        "lsp"
        "path"
        "buffer"
      ];

      # Use colorful-menu
      completion.menu.draw = lib.generators.mkLuaInline /* lua */ '' {
        columns = { { "kind_icon" }, { "label", gap = 1 } },
        components = {
          label = {
            text = function(ctx)
              return require("colorful-menu").blink_components_text(ctx);
            end,
            highlight = function(ctx)
              return require("colorful-menu").blink_components_highlight(ctx)
            end,
          },
        }
      },
      '';

      keymap = {
        preset = "none"; # No default keybinds

        # When we press <esc> and hide the completion menu
        # we normally stay in insert mode, this is anyoing,
        # so we run "hide" and return false so the fallback
        # runs and we return to normal mode without having
        # to press <esc> twice.
        "<esc>" = [
          (lib.generators.mkLuaInline /* lua */ ''
            function(cmp)
              cmp["hide"]();
              return false;
            end
          '')
          "fallback"
        ];

        # Disable tab
        "<Tab>" = ["fallback"];
        "<S-Tab>" = ["fallback"];

        "<C-e>" = ["hide" "fallback"];

        "<CR>" = ["select_and_accept" "fallback"];
        "<C-y>" = ["select_and_accept" "fallback"];

        "<C-n>" = ["select_next" "fallback"];
        "<C-p>" = ["select_prev" "fallback"];

        "<C-u>" = ["scroll_documentation_up" "fallback"];
        "<C-d>" = ["scroll_documentation_down" "fallback"];

        "<C-Space>" = ["show" "show_documentation" "hide_documentation"];
        "<C-k>" = ["show_signature" "hide_signature" "fallback"]; # idk this doesnt seem to work
      };
    };
  };
}
