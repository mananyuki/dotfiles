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
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = [ ];

  # Required for nix-darwin to manage shell environment
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Register Nix fish as a valid login shell
  environment.shells = [ "/etc/profiles/per-user/${username}/bin/fish" ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  system.stateVersion = 5;
}
