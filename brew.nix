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
    mutableTaps = true; # was false — caused "Permission denied" on all external taps
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";   # removes anything not declared here
      autoUpdate = true; # runs `brew update` on each switch
      upgrade = true;    # runs `brew upgrade` on each switch
    };
    taps = builtins.attrNames config.nix-homebrew.taps ++ [
      "dopplerhq/cli"
      "fwartner/tap"
      "jakehilborn/jakehilborn"
      "mongodb/brew"
      "render-oss/render"
    ];

    # CLI tools that require taps or are not available in nixpkgs
    brews = [
      "dopplerhq/cli/doppler"
      "fwartner/tap/mac-cleanup"
      "gh"
      "jakehilborn/jakehilborn/displayplacer"
      "nvm"   # Node version manager (node@22 removed — redundant)
      "pyenv" # Python version manager
      "render-oss/render/render"
    ];

    # GUI apps (.app)
    casks = [
      "1password-cli"
      "blackhole-16ch"
      "claude"
      "claude-code"  # moved from brews — it's a .app cask, not a formula
      "discord"
      "flutter"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "gstreamer-runtime"
      "lens"
      "ngrok"
      "react-native-debugger"
      "slack"
      "spotify"
      "whatsapp"
      "wispr-flow"
      "xquartz"
    ];
  };
}
