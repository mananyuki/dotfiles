zinit wait lucid for \
    zsh-users/zsh-history-substring-search \
    softmoth/zsh-vim-mode \
    zdharma-continuum/history-search-multi-word \
    mollifier/anyframe \
    OMZ::plugins/kubectl \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  blockf \
    zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions
