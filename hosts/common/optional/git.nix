{ pkgs, config, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    config = {
      user = {
        name = config.hostSpec.handle;
        email = config.hostSpec.email;
      };
      safe.directory = [ "/etc/nixos" ];

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
