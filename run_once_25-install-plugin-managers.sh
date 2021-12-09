#!/bin/bash

# tpm
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# packer.nvim
if [ ! -d ~/.local/share/nvim/site/pack/packer/opt/packer.nvim ]; then
  git clone https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/opt/packer.nvim
fi
