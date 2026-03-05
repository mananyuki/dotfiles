set -g fish_greeting
set -g fish_features no-query-term

# Local config override
if test -e $XDG_CONFIG_HOME/fish/config.local.fish
    source $XDG_CONFIG_HOME/fish/config.local.fish
end

# Transitional: Homebrew and mise (remove in Block 2/4)
/opt/homebrew/bin/brew shellenv | source
_evalcache mise activate fish

# Nix paths (must be AFTER mise activate, which overwrites PATH)
set --prepend -gx PATH /nix/var/nix/profiles/default/bin /run/current-system/sw/bin /etc/profiles/per-user/$USER/bin
