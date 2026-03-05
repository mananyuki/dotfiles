{ configDir, ... }:
{
  xdg.configFile = {
    "ghostty/config".source = configDir + "/ghostty/config";
    "zellij/config.kdl".source = configDir + "/zellij/config.kdl";
    "aerospace/aerospace.toml".source = configDir + "/aerospace/aerospace.toml";
    "aerospace/pip-move.sh" = {
      source = configDir + "/aerospace/pip-move.sh";
      executable = true;
    };
    "helix/config.toml".source = configDir + "/helix/config.toml";
    "karabiner/karabiner.json".source = configDir + "/karabiner/karabiner.json";
    "nvim" = {
      source = configDir + "/nvim";
      recursive = true;
    };
  };

  home.file = {
    ".codex/AGENTS.md".source = configDir + "/codex/AGENTS.md";
    ".claude/CLAUDE.md".source = configDir + "/claude/CLAUDE.md";
    ".claude/settings.json".source = configDir + "/claude/settings.json";
    ".claude/statusline-command.sh" = {
      source = configDir + "/claude/statusline-command.sh";
      executable = true;
    };
  };
}
