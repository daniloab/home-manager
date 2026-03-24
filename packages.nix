{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core CLI tools
    ripgrep
    fd
    jq
    fzf
    bat
    eza
    lazygit
    # git is managed by git.nix — removed from here

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
