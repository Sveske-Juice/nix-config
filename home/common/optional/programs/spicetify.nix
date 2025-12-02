{
  pkgs,
  inputs,
  ...
}:
{
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        fullAppDisplay
      ];
      enabledCustomApps = with spicePkgs.apps; [ ];
      enabledSnippets = with spicePkgs.snippets; [ ];

      # Managed by stylix
      # theme = spicePkgs.themes.catppuccin;
      # colorScheme = "mocha";
    };
}
