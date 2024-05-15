#!/bin/zsh

COMPLETION_DIR="$ZSH_CACHE_DIR/completions"
if [[ ! -d $COMPLETION_DIR ]]; then
  mkdir -p $COMPLETION_DIR
fi

if [[ $commands[atuin] ]]; then
  atuin gen-completion --shell zsh > $COMPLETION_DIR/_atuin
fi
if [[ $commands[aqua] ]]; then
  aqua completion zsh > $COMPLETION_DIR/_aqua
fi
if [[ $commands[starship] ]]; then
  starship completions zsh > $COMPLETION_DIR/_starship
fi
if [[ $commands[kubectl] ]]; then
  kubectl completion zsh > $COMPLETION_DIR/_kubectl
fi
if [[ $commands[eksctl] ]]; then
  eksctl completion zsh > $COMPLETION_DIR/_eksctl
fi
if [[ $commands[helm] ]]; then
  helm completion zsh > $COMPLETION_DIR/_helm
fi
