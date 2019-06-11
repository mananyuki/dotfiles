bindkey -v

# zplug
if [[ -f $ZPLUG_HOME/init.zsh ]]; then
    export ZPLUG_LOADFILE="$ZDOTDIR/zplug.zsh"
    source $ZPLUG_HOME/init.zsh

    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
        echo
    fi
    zplug load
fi

# kubernetes
if [[ -f /usr/local/opt/kube-ps1/share/kube-ps1.sh ]]; then
    source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
    PS1='$(kube_ps1)'$PS1
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# anyframe
zstyle ":anyframe:selector:" use fzf
bindkey '^b' anyframe-widget-checkout-git-branch
bindkey '^g' anyframe-widget-cd-ghq-repository

# anyenv
[ $commands[anyenv] ] && eval "$(anyenv init - zsh)"

# direnv
[ $commands[direnv] ] && eval "$(direnv hook zsh)"

# gettext
if [[ -d /usr/local/opt/gettext/bin ]]; then
    export PATH="/usr/local/opt/gettext/bin:$PATH"
fi

# load local settings
if [[ -f $ZDOTDIR/zshrc.local ]]; then
    source $ZDOTDIR/zshrc.local
fi
