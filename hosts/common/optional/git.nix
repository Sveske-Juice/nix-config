{
  pkgs,
  config,
lib,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    config = {
      user = {
        name = config.hostSpec.handle;
        email = config.hostSpec.email;
        signingkey = lib.mkIf (config.hostSpec.publicGPGKey != null) config.hostSpec.publicGPGKey;
      };
      safe.directory = [ "/etc/nixos" ];
      commit = {
        gpgsign = lib.mkIf (config.hostSpec.publicGPGKey != null) true;
      };

      core = {
        whitespace = "error";
      };
      status = {
        branch = true;
        short = true;
        showStash = true;
      };
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      pull = {
        rebase = true;
      };
      rebase = {
        autoStash = true;
      };
      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
      };
    };
  };
}
