{ pkgs, ... }:

{
  home.packages = with pkgs; [ lazygit ];

  programs.lazygit = {
    enable = true;
    settings = {
      customCommands = [
        {
          key = "<c-a>";
          context = "files";
          command = ''claude -p "Look at the staged git changes and write a conventional commit message. Run git commit directly with that message. Do not ask for confirmation."'';
          output = "terminal";
          description = "AI commit with Claude";
        }
      ];
      gui.nerdFontsVersion = "3";
    };
  };
}
