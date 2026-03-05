{ pkgs, configDir, ... }:
{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "fish-ghq";
        src = pkgs.fetchFromGitHub {
          owner = "decors";
          repo = "fish-ghq";
          rev = "cafaaabe63c124bf0714f89ec715cfe9ece87fa2";
          hash = "sha256-6b1zmjtemNLNPx4qsXtm27AbtjwIZWkzJAo21/aVZzM=";
        };
      }
      {
        name = "fish-evalcache";
        src = pkgs.fetchFromGitHub {
          owner = "kyohsuke";
          repo = "fish-evalcache";
          rev = "d71c0f365eddfa79f2080695fd58a2e3cb298b3a";
          hash = "sha256-kQPbW+zFqqILDCeYitPv8sTNq17hS+fRRLtapi9Rp3Q=";
        };
      }
    ];

    shellAbbrs = {
      k = "kubectl";
      lzd = "lazydocker";
      lg = "lazygit";
    };

    shellInit = builtins.readFile (configDir + "/fish/shellInit.fish");
    interactiveShellInit = builtins.readFile (configDir + "/fish/interactiveShellInit.fish");
  };
}
