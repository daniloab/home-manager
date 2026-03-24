{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./gh.nix
  ];

  home.username = "daniloassis";
  home.homeDirectory = "/Users/daniloassis";

  home.stateVersion = "24.11";
}
