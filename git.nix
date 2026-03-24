{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    lfs.enable = true;

    userName = "daniloab";
    userEmail = "daniloassis.ti@gmail.com";

    ignores = [
      "**/.claude/settings.local.json"
    ];

    aliases = {
      co = "checkout";
      st = "status";
      cob = "checkout -b";
      cim = "commit -m";
      pom = "pull origin master";
      poma = "pull origin main";
      pod = "pull origin dev";
      com = "checkout master";
      coma = "checkout main";
      cod = "checkout dev";
      po = "pull";
      pso = "push";
      lg = "log --pretty=format:'%Cred%h%Creset %C(bold)%cr%Creset %Cgreen<%an>%Creset %s' --max-count=30";
      cleanbranch = "! git branch --merged | grep -v '*' | grep -v master | xargs -n 1 git branch -D";
      alias = "! git config --get-regexp ^alias\\\\. | sed -e s/^alias\\\\.// -e s/\\\\ /\\\\ =\\\\ /";
    };

    extraConfig = {
      credential."https://github.com" = {
        helper = [
          ""
          "!/opt/homebrew/bin/gh auth git-credential"
        ];
      };
      credential."https://gist.github.com" = {
        helper = [
          ""
          "!/opt/homebrew/bin/gh auth git-credential"
        ];
      };
    };
  };
}
