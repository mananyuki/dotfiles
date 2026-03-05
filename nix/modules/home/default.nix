{ configDir, ... }:
{
  imports = [
    ./fish.nix
    ./git.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  xdg.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile (configDir + "/starship.toml"));
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };
}
