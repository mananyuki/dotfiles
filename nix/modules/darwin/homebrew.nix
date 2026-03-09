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
    ];

    casks = [
      "nikitabobko/tap/aerospace"
      "chatgpt"
      "claude"
      "cmux"
      "codex-app"
      "cursor"
      "deskpad"
      "discord"
      "firefox"
      "font-line-seed-jp"
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
