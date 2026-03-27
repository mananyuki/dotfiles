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
    ];

    functions = {
      claude = {
        wraps = "claude";
        body = "caffeinate -dis (command -s claude) $argv";
      };
    };

    shellAbbrs = {
      k = "kubectl";
      lzd = "lazydocker";
      lg = "lazygit";
    };

    shellInit = builtins.readFile (configDir + "/fish/shellInit.fish");
    interactiveShellInit = builtins.readFile (configDir + "/fish/interactiveShellInit.fish");
  };
}
