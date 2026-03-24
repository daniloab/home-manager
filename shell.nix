{ config, pkgs, ... }:

let
  sharedAliases = import ./aliases.nix;

  sharedInitExtra = ''
    # ── Git user ──
    export GIT_USER=daniloab
    export GITHUB_USER=daniloab

    # ── Java / Android ──
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.12.jdk/Contents/Home
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools

    # ── Other env vars ──
    export GO111MODULE=on

    # ── pnpm ──
    export PNPM_HOME="/Users/daniloassis/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # ── bun ──
    export BUN_INSTALL="$HOME/.bun"
    export PATH=$BUN_INSTALL/bin:$PATH

    # ── yarn ──
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

    # ── cargo ──
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

    # ── uv ──
    [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

    # ── NVM ──
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # ── Google Cloud SDK ──
    export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"

    # ── opencode ──
    export PATH=/Users/daniloassis/.opencode/bin:$PATH

    # ── Secrets ──
    [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

    # ── Git account switch ──
    source "$HOME/.git-acc"

    # ── Kill port function ──
    killport() { lsof -ti :"$1" | xargs kill -9; }

    # ── aliases: quick reference ──
    aliases() {
      echo "Git:"
      echo "  gpprod  -> git pull origin prod"
      echo "  gcoprod -> git co prod"
      echo "  gpsprod -> git push origin"
      echo ""
      echo "Nix:"
      echo "  ns      -> darwin-rebuild switch"
      echo "  nb      -> darwin-rebuild build"
      echo "  nrb     -> darwin-rebuild rollback"
      echo "  nup     -> nix flake update"
      echo ""
      echo "Other:"
      echo "  ca       -> claude --agentic"
      echo "  cstd     -> claude --dangerously-skip-permissions"
      echo "  wt [name]  -> worktree + tmux session"
      echo "  wtrm [name]-> remove worktree + tmux session + branch"
      echo "  cw [name]  -> worktree + launch claude"
      echo "  cwls       -> list all worktrees"
      echo "  cwrm [name]-> remove worktree + branch"
      echo "  envsource  -> load .env into shell"
      echo "  umbrella   -> launch umbrella panel"
      echo "  killport   -> kill process on port (e.g. killport 3000)"
      echo "  ealias     -> edit shell.nix"
    }

    # ── envsource: load .env file into current shell ──
    envsource() {
      if [ -z "$1" ]; then echo "Usage: envsource <file>"; return 1; fi
      while IFS= read -r line; do
        # skip comments and blank lines
        case "$line" in \#*|"") continue ;; esac
        local key="''${line%%=*}"
        local val="''${line#*=}"
        export "$key"="$val"
        echo "Exported $key"
      done < "$1"
    }

    # ── Git worktree helpers ──
    _git_clean_stale_lock() {
      local git_dir
      git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 0
      local lock="$git_dir/index.lock"
      if [ -f "$lock" ]; then
        if ! lsof "$lock" >/dev/null 2>&1; then
          rm -f "$lock"
          echo "Removed stale index.lock"
        fi
      fi
    }

    # ── cw: Claude Worktree (persistent, with branch management) ──
    # Usage:
    #   cw              → fzf pick existing worktree
    #   cw name         → create worktree + branch "name", cd + launch claude
    #   cw name branch  → create worktree from existing branch
    #   cwls            → list all worktrees
    #   cwrm [name]     → remove worktree + branch (auto-detects current)
    #   cwrm -f [name]  → force remove even with uncommitted changes
    cw() {
      local git_root
      git_root=$(git rev-parse --show-toplevel 2>/dev/null)
      if [ -z "$git_root" ]; then echo "cw: not a git repo"; return 1; fi
      _git_clean_stale_lock

      local name="$1"
      local branch="$2"
      local main_root
      main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
      local repo_name
      repo_name=$(basename "$main_root")
      local wt_base
      wt_base=$(dirname "$main_root")

      # No name → fzf pick existing worktree
      if [ -z "$name" ]; then
        local wt_dir="$wt_base/$repo_name.worktrees"
        if [ ! -d "$wt_dir" ] || [ -z "$(command ls "$wt_dir" 2>/dev/null)" ]; then
          echo "cw: no worktrees found. Usage: cw <name> [branch]"
          return 1
        fi
        name=$(command ls "$wt_dir" | fzf --prompt="worktree> " --height=40%)
        [ -z "$name" ] && return 1
      fi

      local wt_path="$wt_base/$repo_name.worktrees/$name"

      # Worktree already exists → just cd + claude
      if [ -d "$wt_path" ]; then
        echo "Switching to existing worktree: $wt_path"
        cd "$wt_path" && claude
        return 0
      fi

      # Create new worktree
      git fetch origin 2>/dev/null
      local base_branch
      base_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ -z "$base_branch" ] || [ "$base_branch" = "HEAD" ]; then
        echo "cw: detached HEAD — checkout a branch first"
        return 1
      fi

      mkdir -p "$wt_base/$repo_name.worktrees"

      if [ -n "$branch" ]; then
        # Explicit branch provided
        if git show-ref --verify --quiet "refs/heads/$branch"; then
          git worktree add "$wt_path" "$branch"
        elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
          git worktree add --track -b "$branch" "$wt_path" "origin/$branch"
        else
          git worktree add -b "$branch" "$wt_path" "$base_branch"
        fi
      else
        git worktree add -b "$name" "$wt_path" "$base_branch"
      fi

      if [ $? -ne 0 ]; then echo "cw: failed to create worktree"; return 1; fi

      echo "Created worktree at $wt_path (from $base_branch)"

      # Run .setup script if it exists
      local setup_file="$wt_base/$repo_name.worktrees/.setup"
      if [ -f "$setup_file" ]; then
        echo "Running .setup script..."
        (cd "$wt_path" && sh "$setup_file")
      fi

      cd "$wt_path" && claude
    }

    cwls() {
      git worktree list "$@"
    }

    cwrm() {
      local git_root
      git_root=$(git rev-parse --show-toplevel 2>/dev/null)
      if [ -z "$git_root" ]; then echo "cwrm: not a git repo"; return 1; fi

      local force=0
      local name=""
      for arg in "$@"; do
        case "$arg" in
          -f|--force) force=1 ;;
          *) name="$arg" ;;
        esac
      done

      local main_root
      main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
      local repo_name
      repo_name=$(basename "$main_root")
      local wt_base
      wt_base=$(dirname "$main_root")

      # No name → fzf pick
      if [ -z "$name" ]; then
        local wt_dir="$wt_base/$repo_name.worktrees"
        if [ ! -d "$wt_dir" ] || [ -z "$(command ls "$wt_dir" 2>/dev/null)" ]; then
          echo "cwrm: no worktrees found"
          return 1
        fi
        name=$(command ls "$wt_dir" | fzf --prompt="remove> " --height=40%)
        [ -z "$name" ] && return 1
      fi

      local wt_path="$wt_base/$repo_name.worktrees/$name"
      if [ ! -d "$wt_path" ]; then echo "cwrm: no worktree '$name'"; return 1; fi

      local branch
      branch=$(git -C "$wt_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

      if [ "$force" -eq 1 ]; then
        git worktree remove --force "$wt_path"
      else
        git worktree remove "$wt_path" || { echo "cwrm: has changes — use cwrm -f $name"; return 1; }
      fi

      # Clean up branch
      if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
        if [ "$force" -eq 1 ]; then
          git branch -D "$branch" 2>/dev/null
        else
          git branch -d "$branch" 2>/dev/null
        fi
        echo "Removed worktree '$name' and branch '$branch'"
      else
        echo "Removed worktree '$name'"
      fi
    }

    # ── wt: Git Worktree + tmux session ──
    # Usage:
    #   wt              → fzf pick existing worktree (switches tmux session)
    #   wt name         → create worktree + tmux session, switch to it
    #   wt name branch  → create worktree from existing branch
    #   wtrm [name]     → remove worktree + tmux session + branch
    #   wtrm -f [name]  → force remove even with uncommitted changes
    wt() {
      local git_root
      git_root=$(git rev-parse --show-toplevel 2>/dev/null)
      if [ -z "$git_root" ]; then echo "wt: not a git repo"; return 1; fi
      _git_clean_stale_lock

      local name="$1"
      local branch="$2"
      local main_root
      main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
      local repo_name
      repo_name=$(basename "$main_root")
      local wt_base
      wt_base=$(dirname "$main_root")

      # No name → fzf pick existing worktree
      if [ -z "$name" ]; then
        if [ -z "$TMUX" ]; then echo "wt: not in tmux"; return 1; fi
        local wt_dir="$wt_base/$repo_name.worktrees"
        if [ ! -d "$wt_dir" ] || [ -z "$(command ls "$wt_dir" 2>/dev/null)" ]; then
          echo "wt: no worktrees found. Usage: wt <name> [branch]"
          return 1
        fi
        name=$(command ls "$wt_dir" | fzf --prompt="worktree> " --height=40%)
        [ -z "$name" ] && return 1
      fi

      local wt_path="$wt_base/$repo_name.worktrees/$name"

      # If in tmux, check for existing session and switch to it
      if [ -n "$TMUX" ]; then
        local parent_session
        parent_session=$(tmux display-message -p '#{session_name}' | cut -d'/' -f1)
        local session_name="$parent_session/$name"

        if tmux has-session -t "=$session_name" 2>/dev/null; then
          tmux switch-client -t "=$session_name"
          return 0
        fi
      fi

      local is_new=0

      # Worktree doesn't exist → create it
      if [ ! -d "$wt_path" ]; then
        git fetch origin 2>/dev/null
        local base_branch
        base_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -z "$base_branch" ] || [ "$base_branch" = "HEAD" ]; then
          echo "wt: detached HEAD — checkout a branch first"
          return 1
        fi

        mkdir -p "$wt_base/$repo_name.worktrees"

        if [ -n "$branch" ]; then
          if git show-ref --verify --quiet "refs/heads/$branch"; then
            git worktree add "$wt_path" "$branch"
          elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            git worktree add --track -b "$branch" "$wt_path" "origin/$branch"
          else
            git worktree add -b "$branch" "$wt_path" "$base_branch"
          fi
        else
          git worktree add -b "$name" "$wt_path" "$base_branch"
        fi

        if [ $? -ne 0 ]; then echo "wt: failed to create worktree"; return 1; fi
        echo "Created worktree at $wt_path (from $base_branch)"
        is_new=1
      fi

      # If in tmux → create session and switch
      if [ -n "$TMUX" ]; then
        local parent_session
        parent_session=$(tmux display-message -p '#{session_name}' | cut -d'/' -f1)
        local session_name="$parent_session/$name"

        tmux new-session -d -s "$session_name" -c "$wt_path"

        # Run .setup if new worktree
        if [ "$is_new" -eq 1 ]; then
          local setup_file="$wt_base/$repo_name.worktrees/.setup"
          if [ -f "$setup_file" ]; then
            tmux send-keys -t "=$session_name" "sh '$setup_file'" Enter
          fi
        fi

        tmux switch-client -t "=$session_name"
      else
        # Not in tmux → just cd
        echo "Not in tmux — cd to $wt_path"
        cd "$wt_path"
      fi
    }

    wtrm() {
      local git_root
      git_root=$(git rev-parse --show-toplevel 2>/dev/null)
      if [ -z "$git_root" ]; then echo "wtrm: not a git repo"; return 1; fi

      local force=0
      local name=""
      for arg in "$@"; do
        case "$arg" in
          -f|--force) force=1 ;;
          *) name="$arg" ;;
        esac
      done

      local main_root
      main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
      local repo_name
      repo_name=$(basename "$main_root")
      local wt_base
      wt_base=$(dirname "$main_root")

      # Auto-detect from current tmux session name
      if [ -z "$name" ] && [ -n "$TMUX" ]; then
        local current_session
        current_session=$(tmux display-message -p '#{session_name}')
        case "$current_session" in
          */*)
            name="''${current_session#*/}"
            printf "wtrm: remove worktree '$name'? [y/N] "
            read -r confirm
            case "$confirm" in [yY]) ;; *) return 0 ;; esac
            ;;
        esac
      fi

      # Still no name → fzf pick
      if [ -z "$name" ]; then
        local wt_dir="$wt_base/$repo_name.worktrees"
        if [ ! -d "$wt_dir" ] || [ -z "$(command ls "$wt_dir" 2>/dev/null)" ]; then
          echo "wtrm: no worktrees found"
          return 1
        fi
        name=$(command ls "$wt_dir" | fzf --prompt="remove> " --height=40%)
        [ -z "$name" ] && return 1
      fi

      local wt_path="$wt_base/$repo_name.worktrees/$name"
      if [ ! -d "$wt_path" ]; then echo "wtrm: no worktree '$name'"; return 1; fi

      local branch
      branch=$(git -C "$wt_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

      # If in tmux and removing current session → switch to parent first
      local current_session=""
      local self_rm=0
      if [ -n "$TMUX" ]; then
        current_session=$(tmux display-message -p '#{session_name}')
        local target_session
        target_session=$(tmux list-sessions -F '#{session_name}' | grep "/$name$" | head -1)
        if [ -n "$target_session" ] && [ "$current_session" = "$target_session" ]; then
          self_rm=1
          local parent_session
          parent_session="''${current_session%%/*}"
          if ! tmux has-session -t "=$parent_session" 2>/dev/null; then
            parent_session=$(tmux list-sessions -F '#{session_name}' | grep -v "^$current_session$" | head -1)
            if [ -z "$parent_session" ]; then echo "wtrm: no other session to switch to"; return 1; fi
          fi
          tmux switch-client -t "=$parent_session"
          if [ "$force" -eq 1 ]; then
            tmux run-shell -b "tmux kill-session -t '=$current_session'; git -C '$main_root' worktree remove --force '$wt_path'; git -C '$main_root' branch -D '$branch' 2>/dev/null"
          else
            tmux run-shell -b "tmux kill-session -t '=$current_session'; git -C '$main_root' worktree remove '$wt_path'; git -C '$main_root' branch -d '$branch' 2>/dev/null"
          fi
          return 0
        fi

        # Not current session but still in tmux → kill the target session
        if [ -n "$target_session" ]; then
          tmux kill-session -t "=$target_session"
        fi
      fi

      # Remove worktree
      if [ "$force" -eq 1 ]; then
        git worktree remove --force "$wt_path"
      else
        git worktree remove "$wt_path" || { echo "wtrm: has changes — use wtrm -f $name"; return 1; }
      fi

      # Clean up branch
      if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
        if [ "$force" -eq 1 ]; then
          git branch -D "$branch" 2>/dev/null
        else
          git branch -d "$branch" 2>/dev/null
        fi
        echo "Removed worktree '$name' and branch '$branch'"
      else
        echo "Removed worktree '$name'"
      fi
    }
  '';
in
{
  programs.bash = {
    enable = true;
    shellAliases = sharedAliases;
    initExtra = sharedInitExtra + ''
      # ── Bash-specific ──
      export SHELL=/bin/bash
      HISTFILESIZE=2000
      HISTSIZE=1000
      HISTFILE=/Users/daniloassis/.bash_eternal_history
      PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

      export LSCOLORS=ExFxBxDxCxegedabagacad
      export TERM=xterm-256color
      export CLICOLOR=1
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = sharedAliases;
    profileExtra = ''
      # ── Homebrew ──
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # ── Toolbox App ──
      export PATH="$PATH:/usr/local/bin"

      # ── OrbStack ──
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
    '';
    initContent = sharedInitExtra + ''
      # ── Zsh-specific ──
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8

      export CLICOLOR=1
      export LSCOLORS=ExFxBxDxCxegedabagacad

      # ── FZF ──
      source <(fzf --zsh)
    '';
  };
}
