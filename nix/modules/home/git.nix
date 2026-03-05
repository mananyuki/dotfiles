{ lib, configDir, ... }:
let
  ignoreFile = builtins.readFile (configDir + "/git/ignore");
  ignores = builtins.filter (line: line != "") (lib.splitString "\n" ignoreFile);
in
{
  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options = {
        syntax-theme = "Nord";
        navigate = true;
        side-by-side = true;
      };
    };

    extraConfig = {
      ghq.root = [
        "~/src"
        "~/go/src"
      ];
      init.defaultBranch = "main";
      rebase.autostash = true;
    };

    includes = [
      { path = "~/.config/git/local"; }
    ];

    inherit ignores;
  };
}
