{ pkgs, configDir, ... }:
{
  imports = [
    ./dotfiles.nix
    ./fish.nix
    ./git.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  xdg.enable = true;

  # Nix-first CLI tools (moved from Homebrew)
  home.packages = with pkgs; [
    coreutils
    curl
    gnupg
    gnused
    helix
    lua
    luarocks
    neovim
    pandoc
    tree
    unzip
    zellij
  ];

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
