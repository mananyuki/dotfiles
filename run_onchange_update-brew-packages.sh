#!/bin/zsh

# Brewfile hash: {{ include "dot_Brewfile.tmpl" | sha256sum }}
brew bundle --global
brew bundle --global cleanup --force
