{ pkgs, ... }:

{
  # Declare the primary user
  system.primaryUser = "daniloassis";
  users.users.daniloassis = {
    name = "daniloassis";
    home = "/Users/daniloassis";
  };

  # Let Determinate manage the Nix daemon
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (available to all users)
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      minimize-to-application = true; # minimizes windows to app icon instead of dock shelf
      tilesize = 48;                  # dock icon size
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;  # shows full path breadcrumb at bottom of Finder
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;             # allows key repeat in neovim (disables accent picker)
      NSAutomaticSpellingCorrectionEnabled = false; # no autocorrect
      NSAutomaticQuoteSubstitutionEnabled = false;  # no smart quotes (breaks code)
    };
  };

  # Set the platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Used for backwards compatibility
  system.stateVersion = 5;
}
