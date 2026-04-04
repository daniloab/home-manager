{ pkgs, ... }:

let
  vercel = pkgs.stdenv.mkDerivation rec {
    pname = "vercel";
    version = "50.38.2";

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.cacert ];

    dontUnpack = true;

    buildPhase = ''
      export HOME=$TMPDIR
      export PATH=${pkgs.nodejs}/bin:$PATH
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export NODE_EXTRA_CA_CERTS=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      ${pkgs.nodejs}/bin/npm install --prefix $TMPDIR/vercel vercel@${version}
    '';

    installPhase = ''
      mkdir -p $out/lib $out/bin
      cp -r $TMPDIR/vercel/node_modules $out/lib/
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/vercel \
        --add-flags "$out/lib/node_modules/vercel/dist/index.js"
    '';

    meta = with pkgs.lib; {
      description = "Vercel CLI";
      homepage = "https://vercel.com";
      license = licenses.asl20;
      mainProgram = "vercel";
    };
  };
in
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
    kubernetes-helm
    mongosh
    mongodb-tools
    neovim
    nginx
    pnpm
    php
    phpPackages.composer
    redis
    rustup
    stern
    subversion
    uv

    # Utilities
    vercel
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
    options = [ "--cmd=cd" ]; # overrides cd with zoxide: cd foo, cdi foo (interactive)
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
