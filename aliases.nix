{
  # Python
  pip = "pip3";
  python = "python3";

  # JS
  iarn = "yarn";
  tsxw = "tsx watch";

  # Terminal
  term = "open -a Terminal $(pwd)";

  # Git
  gc = "git clone";
  gcim = "git commit -m";
  gcoma = "git checkout main";
  gcoprod = "git co prod";
  gcos = "git checkout staging";
  gpcf = "gh pr create --fill";
  ghpm = "gh pr merge";
  gpoma = "git pull origin main";
  gpos = "git pull origin staging";
  gpprod = "git pull origin prod";
  gpsprod = "git push origin";

  # Node/Test
  npr = "npm run test";
  npru = "npm run test:u";

  # Claude
  ca = "claude --agentic";
  cstd = "claude --dangerously-skip-permissions";

  # Make shortcuts
  mkdl = "make dev ENV=local";
  mkd = "make dev";
  mks = "make setup";

  # Umbrella
  umbrella = "lsof -ti:3333 | xargs kill 2>/dev/null; cd ~/umbrella-panel && uv run umbrella &>/dev/null & sleep 0.5 && open http://localhost:3333";

  # Zsh/shell helpers
  szsh = "source ~/.zshrc";
  ezsh = "vim ~/.zshrc";
  ealias = "vim ~/home-manager/aliases.nix";

  # Git cleanup
  clean_branches = "git branch --merged | grep -v '*' | grep -v master | xargs -n 1 git branch -D";

  # Modern CLI replacements
  ls = "eza -lag";
  cat = "bat";
}
