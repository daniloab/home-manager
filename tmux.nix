{ pkgs, ... }:

{
  home.packages = with pkgs; [ tmux ];

  programs.tmux = {
    enable = true;
    prefix = "C-space";
    terminal = "screen-256color";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    historyLimit = 50000;
    extraConfig = ''
      set -g renumber-windows on
      set -g escape-time 1
      set -g status-interval 5

      bind-key o split-window -h -c "#{pane_current_path}" opencode
      bind-key l split-window -h -c "#{pane_current_path}" lazygit
      bind-key c new-window -c "#{pane_current_path}"
      bind-key '"' split-window -c "#{pane_current_path}"
      bind-key % split-window -h -c "#{pane_current_path}"
      bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded!"
    '';
  };
}

