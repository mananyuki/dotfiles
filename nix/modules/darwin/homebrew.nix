{ lib, profile, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };

    taps = [
      "nikitabobko/tap"
      "steipete/tap"
      "datadog-labs/pack"
    ];

    # CLI tools not available in nixpkgs or needed by Homebrew itself
    brews = [
      "deck"
      "fish" # login shell (transitional: until Nix fish is registered)
      "mas"
      "subversion" # required by some font casks
      "zsh"
      "worktrunk"
      "datadog-labs/pack/pup"
      "steipete/tap/gogcli"
    ] ++ lib.optionals (profile == "work") [
      "awscli"
    ];

    casks = [
      "aerospace"
      "chatgpt"
      "claude"
      "cmux"
      "codex-app"
      "cursor"
      "deskpad"
      "discord"
      "firefox"
      "font-biz-udgothic"
      "font-biz-udmincho"
      "font-jetbrains-mono-nerd-font"
      "font-line-seed-jp"
      "font-noto-sans"
      "font-noto-sans-cjk-jp"
      "font-noto-serif"
      "font-ubuntu-mono-nerd-font"
      "gcloud-cli"
      "ghostty"
      "github"
      "google-chrome"
      "karabiner-elements"
      "obs"
      "obsidian"
      "orbstack"
      "sf-symbols"
      "slack"
      "visual-studio-code"
    ] ++ lib.optionals (profile == "home") [
      "balenaetcher"
    ] ++ lib.optionals (profile == "work") [
      "microsoft-edge"
      "session-manager-plugin"
      "zoom"
    ];

    masApps = {
      "Kindle" = 302584613;
      "LINE" = 539883307;
    } // lib.optionalAttrs (profile == "home") {
      "Affinity Publisher" = 881418622;
      "Prime Video" = 545519333;
    };
  };
}
