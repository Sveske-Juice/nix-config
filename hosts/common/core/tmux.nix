{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      # Prefix binding
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Enable mouse support
      set -g mouse on

      # Clear screen shortcut
      bind C-l send-keys 'C-l'

      run-shell ${pkgs.tmuxPlugins.vim-tmux-navigator}/share/tmux-plugins/vim-tmux-navigator/vim-tmux-navigator.tmux
    '';
  };
}
