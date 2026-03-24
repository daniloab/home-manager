# Danilo's macOS Setup (nix-darwin + Home Manager)

Declarative macOS configuration using [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager). One install, one command, everything configured.

## What's managed

| File | What it does |
|---|---|
| `flake.nix` | Entry point — pins nixpkgs, nix-darwin, home-manager, and homebrew inputs |
| `darwin.nix` | macOS system settings (Dock, Finder, keyboard, Touch ID sudo) |
| `home.nix` | Home Manager entry point — imports all user-level modules |
| `packages.nix` | CLI tools (ripgrep, fd, bat, eza, neovim, pnpm, go, etc.), direnv, zoxide, starship |
| `brew.nix` | Homebrew taps, formulas (nvm, pyenv, doppler), and casks (1Password, Ghostty, Chrome, Slack, etc.) |
| `shell.nix` | Zsh/Bash config — env vars, functions (cw, wt, killport, envsource) |
| `aliases.nix` | Shell aliases shared between zsh and bash |
| `git.nix` | Git config — user, aliases, credential helpers via gh |
| `gh.nix` | GitHub CLI config (SSH protocol, pr checkout alias) |
| `tmux.nix` | Tmux configuration |
| `lazygit.nix` | Lazygit configuration |

## Fresh install

### 1. Install Nix

Install using the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) (recommended):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

This installs Nix with flakes enabled by default.

### 2. Clone this repo

```bash
git clone git@github.com:daniloab/home-manager.git ~/home-manager
```

### 3. Build and apply

```bash
sudo darwin-rebuild switch --flake ~/home-manager#Danilos-MacBook-Pro
```

This single command will:
- Install all CLI tools via nixpkgs
- Install Homebrew and all brews/casks
- Configure macOS system defaults (Dock, Finder, keyboard)
- Set up zsh/bash with aliases, env vars, and functions
- Configure git, gh, direnv, zoxide, and starship

### 4. Activate Home Manager files

After the first `switch`, link dotfiles into your home directory:

```bash
# Find and run the activation script
/nix/var/nix/profiles/system/activate-user 2>/dev/null || \
  find /nix/store -maxdepth 1 -name "*activation-daniloassis" -newer /etc/zshrc | head -1 | xargs bash
```

This creates `~/.zshrc`, `~/.config/git/config`, etc. Only needed on first setup — subsequent `switch` runs handle it.

### 5. Create required dotfiles

```bash
touch ~/.git-acc    # git account switching (sourced by zshrc)
touch ~/.secrets    # secrets/env vars (sourced by zshrc)
```

### 6. Open a new terminal

Your shell is now fully configured.

## Day-to-day usage

### Aliases

After setup, use these shortcuts:

| Alias | Command |
|---|---|
| `ns` | `darwin-rebuild switch --flake ~/home-manager#Danilos-MacBook-Pro` |
| `nb` | `darwin-rebuild build --flake ~/home-manager#Danilos-MacBook-Pro` |
| `nrb` | `darwin-rebuild rollback` |
| `nup` | `nix flake update ~/home-manager` |
| `ealias` | Edit aliases.nix |

### Making changes

1. Edit the relevant `.nix` file
2. Apply: `sudo ns` (or the full `darwin-rebuild switch` command)
3. Open a new terminal tab

### Updating nixpkgs

```bash
nup     # updates flake.lock
sudo ns # rebuilds with new versions
```

### Rolling back

```bash
sudo nrb  # reverts to the previous generation
```

## File structure

```
~/home-manager/
  flake.nix       # inputs + system definition
  flake.lock      # pinned dependency versions
  darwin.nix      # macOS system preferences
  home.nix        # home-manager entry (imports modules below)
  packages.nix    # nix packages + direnv/zoxide/starship
  brew.nix        # homebrew taps, formulas, casks
  shell.nix       # zsh/bash config, env vars, functions
  aliases.nix     # shell aliases (shared by zsh + bash)
  git.nix         # git config
  gh.nix          # github cli config
  tmux.nix        # tmux config
  lazygit.nix     # lazygit config
  CLAUDE.md       # conventions and instructions for Claude Code
```
