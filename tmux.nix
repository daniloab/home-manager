{ pkgs, ... }:

{
  home.packages = with pkgs; [ tmux ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    mouse = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    keyMode = "vi";
    extraConfig = ''
      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New window keeps current path
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with Ctrl+hjkl
      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded"

      # Open opencode/lazygit pane
      bind-key o split-window -h -c "#{pane_current_path}" opencode
      bind-key g split-window -h -c "#{pane_current_path}" lazygit

      # Status bar
      set -g status-position top
      set -g status-style "bg=default,fg=white"
      set -g status-left "#[bold] #S "
      set -g status-right ""
      set -g window-status-format " #I:#W "
      set -g window-status-current-format "#[bold,fg=green] #I:#W "
    '';
  };
}
