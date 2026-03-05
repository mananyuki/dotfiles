{ username, ... }:
{
  imports = [
    ./homebrew.nix
    ./defaults.nix
  ];

  nix.channel.enable = false;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      username
    ];
  };

  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = [ ];

  # Required for nix-darwin to manage shell environment
  programs.zsh.enable = true;
  programs.fish.enable = true;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  system.stateVersion = 5;
}
