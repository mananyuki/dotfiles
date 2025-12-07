set -g fish_greeting

# XDG base directory
if test -z "$XDG_CONFIG_HOME"
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end

if test -z "$XDG_CACHE_HOME"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
    set -gx ZSH_CACHE_DIR "$XDG_CACHE_HOME"
end

if test -z "$XDG_DATA_HOME"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
end

# shell
set -gx SHELL /opt/homebrew/bin/fish

# language
set -gx LANGUAGE "en_US.UTF-8"
set -gx LANG "$LANGUAGE"
set -gx LC_ALL "$LANGUAGE"
set -gx LC_CTYPE "$LANGUAGE"

# editor
set -gx EDITOR nvim
set -gx GIT_EDITOR "$EDITOR"

# golang
set -gx GOPATH "$HOME/go"
set -gx GOBIN "$GOPATH/bin"
fish_add_path $GOBIN

# coursier
set -gx COURSIER_BIN_DIR "$XDG_DATA_HOME/coursier/bin"
fish_add_path $COURSIER_BIN_DIR

# droid
fish_add_path $HOME/.local/bin

# rust
fish_add_path $HOME/.cargo/bin

# kubernetes
abbr -a -- k kubectl
fish_add_path ~/.krew/bin

# zellij
set -gx ZELLIJ_CONFIG_DIR $HOME/.config/zellij
set -gx ZELLIJ_AUTO_ATTACH true

# tools
abbr -a -- lzd lazydocker
abbr -a -- lg lazygit

# load local config
if test -e "$XDG_CONFIG_HOME/fish/config.local.fish"
    source $XDG_CONFIG_HOME/fish/config.local.fish
end

# load kiro shell integration
if command -sq kiro
    string match -q "$TERM_PROGRAM" kiro and . (kiro --locate-shell-integration-path fish)
end

if status is-interactive
    /opt/homebrew/bin/brew shellenv | source
    atuin init fish | source
    starship init fish | source
    mise activate fish | source

    if [ "$TERM" = xterm-ghostty ]
        eval (zellij setup --generate-auto-start fish | string collect)
    end
end
