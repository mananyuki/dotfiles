# Language
set -gx LANGUAGE en_US.UTF-8
set -gx LANG $LANGUAGE
set -gx LC_ALL $LANGUAGE
set -gx LC_CTYPE $LANGUAGE

# Editor
set -gx EDITOR hx
set -gx GIT_EDITOR $EDITOR

# Go
set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin
set -gx GONOSUMCHECK ""
set -gx GOFLAGS -mod=readonly
fish_add_path $GOBIN

# Coursier
set -gx COURSIER_BIN_DIR $XDG_DATA_HOME/coursier/bin
fish_add_path $COURSIER_BIN_DIR

# Local bin
fish_add_path $HOME/.local/bin

# Rust
fish_add_path $HOME/.cargo/bin

# Kubernetes
fish_add_path $HOME/.krew/bin

# Zellij
set -gx ZELLIJ_CONFIG_DIR $HOME/.config/zellij
set -gx ZELLIJ_AUTO_ATTACH true
