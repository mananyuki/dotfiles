zinit light-mode depth=1 for \
  jeffreytse/zsh-vi-mode

zinit wait lucid light-mode for \
  OMZP::kubectl \
  mollifier/anyframe \
  atuinsh/atuin

zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  blockf \
    zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions
