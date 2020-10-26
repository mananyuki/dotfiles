#!/bin/bash

# vim-plug
curl -fLo \
  "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# tpm
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
