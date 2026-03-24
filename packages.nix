{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core CLI tools
    ripgrep
    fd
    jq
    bat
    eza
    glow
    httpie
    tmux

    # Dev tools
    circleci-cli
    cloudflared
    cocoapods
    deno
    flyctl
    go
    k6
    k9s
    kops
    mongosh
    mongodb-tools
    neovim
    nginx
    # nodejs removed — managed by nvm via brew.nix
    pnpm
    php
    phpPackages.composer
    redis
    rustup
    stern
    subversion
    uv

    # Utilities
    dart
    fluxcd
    ledger
    translate-shell
    tree
    ttyd
    yq
  ];

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  programs.lazygit = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    mouse = true;
    terminal = "tmux-256color";
    prefix = "C-a";
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

      # Status bar
      set -g status-position top
      set -g status-style "bg=default,fg=white"
      set -g status-left "#[bold] #S "
      set -g status-right ""
      set -g window-status-format " #I:#W "
      set -g window-status-current-format "#[bold,fg=green] #I:#W "
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
    package = pkgs.direnv.overrideAttrs (old: {
      env = (old.env or {}) // { CGO_ENABLED = "1"; };
    });
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [ "--cmd=j" ]; # j replaces autojump: j foo, ji foo (interactive)
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
      };
      nix_shell = {
        format = "via [$symbol]($style) ";
        symbol = " ";
      };
      nodejs.disabled = true;
      python.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };
}
