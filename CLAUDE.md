# Danilo's nix-darwin + Home Manager Configuration

## Overview

This is a declarative macOS system configuration using **nix-darwin** + **Home Manager** + **nix-homebrew**, managed as a Nix flake. Target machine: `Danilos-MacBook-Pro` (aarch64-darwin).

## Architecture

- `flake.nix` — Entry point. Defines inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew) and wires modules together.
- `darwin.nix` — System-level config: users, macOS defaults (dock, finder, trackpad, keyboard), Touch ID sudo, system packages.
- `brew.nix` — Homebrew taps, brews (CLI tools), and casks (GUI apps). Managed by nix-homebrew with `cleanup = "zap"` (removes undeclared packages).
- `home.nix` — Home Manager entry point. Imports all user-level modules.
- `packages.nix` — Nix packages (CLI tools, dev tools, utilities) and program configs (fzf, lazygit, direnv, zoxide, starship).
- `shell.nix` — Bash and Zsh config: shared env vars, PATH entries, shell functions (worktree helpers `wt`/`cw`, `killport`, `envsource`).
- `aliases.nix` — Shared shell aliases (git, nix, claude, make, modern CLI replacements).
- `git.nix` — Git configuration.
- `gh.nix` — GitHub CLI configuration.
- `tmux.nix` — Tmux configuration.
- `lazygit.nix` — Lazygit configuration.

## Key Commands

```
ns   → darwin-rebuild switch (apply changes)
nb   → darwin-rebuild build
nrb  → darwin-rebuild rollback
nup  → nix flake update
```

## Rules for Claude

1. **Always read this file at the start of a conversation** to understand the repo structure and conventions.
2. **After making changes, propose updating this file** if the change affects the architecture, file responsibilities, or conventions documented here. Ask the user before updating.
3. **Nix conventions:**
   - Homebrew packages go in `brew.nix` — CLI-only tools in `brews`, GUI apps in `casks`.
   - Nix-native packages go in `packages.nix` (prefer nix packages over brew when available and working on macOS).
   - Shell aliases go in `aliases.nix`, shell functions and env vars go in `shell.nix`.
   - Each concern has its own `.nix` file — don't mix responsibilities.
4. **Brew zap is enabled** — any cask/brew removed from `brew.nix` will be uninstalled on next `ns`. Be careful when removing entries.
5. **Keep lists sorted alphabetically** within their sections (casks, brews, packages, aliases).
6. **Don't add comments unless the entry is non-obvious** (e.g., why a package is in brew instead of nix).
