{ pkgs, lib, profile, configDir, llmAgentsPkgs, ... }:
let
  worktrunk = pkgs.callPackage ../../packages/worktrunk.nix { };
  pup = pkgs.callPackage ../../packages/pup.nix { };
  deck = pkgs.callPackage ../../packages/deck.nix { };
  gogcli = pkgs.callPackage ../../packages/gogcli.nix { };
in
{
  imports = [
    ./dotfiles.nix
    ./fish.nix
    ./git.nix
  ];

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  xdg.enable = true;

  home.packages =
    (with pkgs; [
      # Core utilities
      coreutils
      curl
      fd
      gnupg
      gnused
      jq
      ripgrep
      sd
      tree
      unzip

      # Editors & terminal tools
      helix
      neovim
      zellij

      # Version control
      gh
      ghq
      git-lfs
      lazygit

      # Languages & runtimes
      bun
      deno
      go
      jdk11
      nodejs
      rustup
      uv

      # Language tools
      biome
      coursier
      lua
      luarocks
      metals
      pandoc
      ruff
      vale

      # Infrastructure & containers
      buf
      kubectl
      krew
      lazydocker
      mas
      minikube
      terraform
      tflint

      # Build tools
      go-task

      # Dev tools
      duckdb
    ])
    ++ (with llmAgentsPkgs; [
      agent-browser
      claude-code
      codex
      copilot-cli
      gemini-cli
    ])
    ++ [
      deck
      gogcli
      pup
      worktrunk
    ]
    ++ lib.optionals (profile == "work") [
      pkgs.awscli2
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
