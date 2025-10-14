{ pkgs, ... }:
{
  config.vim.lazy.plugins."smartyank.nvim" = {
    package = pkgs.vimPlugins.smartyank-nvim;
    setupModule = "smartyank";
    setupOpts.osc52.ssh_only = false;
    setupOpts.tmux.enabled = false; # use local tmux on host
    # setupOpts.tmux.cmd = [ "tmux" "set-buffer" "-w" ];
  };
}
