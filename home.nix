{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./gh.nix
    ./tmux.nix
    ./lazygit.nix
  ];

  home.username = "daniloassis";
  home.homeDirectory = "/Users/daniloassis";

  home.stateVersion = "24.11";
}
