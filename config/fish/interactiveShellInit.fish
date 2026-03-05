set -g fish_greeting
set -g fish_features no-query-term

# Local config override
if test -e $XDG_CONFIG_HOME/fish/config.local.fish
    source $XDG_CONFIG_HOME/fish/config.local.fish
end

# Homebrew (still needed for casks and subversion)
/opt/homebrew/bin/brew shellenv | source

# Nix paths (must come after brew shellenv to take precedence)
set --prepend -gx PATH /nix/var/nix/profiles/default/bin /run/current-system/sw/bin /etc/profiles/per-user/$USER/bin
