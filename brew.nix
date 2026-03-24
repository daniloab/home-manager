{ config, homebrew-core, homebrew-cask, homebrew-bundle, ... }:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "daniloassis";
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = builtins.attrNames config.nix-homebrew.taps ++ [
      "dopplerhq/cli"
      "fwartner/tap"
      "jakehilborn/jakehilborn"
      "mongodb/brew"
      "render-oss/render"
    ];

    # CLI tools that must stay in Homebrew (tapped, version managers, macOS-specific)
    brews = [
      "claude-code"
      "dopplerhq/cli/doppler"
      "fwartner/tap/mac-cleanup"
      "gh"
      "jakehilborn/jakehilborn/displayplacer"
      "node@14"       # legacy, managed by nvm
      "nvm"           # Node version manager
      "pyenv"         # Python version manager
      "render-oss/render/render"
    ];

    # GUI apps via casks
    casks = [
      "1password-cli"
      "blackhole-16ch"
      "claude"
      "flutter"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "gstreamer-runtime"
      "lens"
      "ngrok"
      "react-native-debugger"
      "xquartz"
    ];
  };
}
