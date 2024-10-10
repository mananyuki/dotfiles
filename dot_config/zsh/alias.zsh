export ABBR_QUIET=1

# lazydocker
if [[ $commands[lazydocker] ]]; then
  abbr -S lzd="lazydocker"
fi

# lazygit
if [[ $commands[lazygit] ]]; then
  abbr -S lg="lazygit"
fi

# kubectl
if [[ $commands[kubectl] ]]; then
  abbr -S k="kubectl"
fi
