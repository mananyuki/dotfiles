set -g fish_greeting
set -g fish_features no-query-term

# Local config override
if test -e $XDG_CONFIG_HOME/fish/config.local.fish
    source $XDG_CONFIG_HOME/fish/config.local.fish
end

# Transitional: Homebrew (remove in Block 5 when all brews are eliminated)
/opt/homebrew/bin/brew shellenv | source

# Nix paths (must be AFTER mise activate, which overwrites PATH)
set --prepend -gx PATH /nix/var/nix/profiles/default/bin /run/current-system/sw/bin /etc/profiles/per-user/$USER/bin
