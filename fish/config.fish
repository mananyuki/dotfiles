# export
set -gx GOPATH $HOME
set -gx GHQ_ROOT $HOME/src
set -gx LC_ALL ja_JP.UTF-8
set -gx LANG ja_JP.UTF-8

# PATH
set -gx PATH $GOPATH/bin $PATH
set -g fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths

# keybind
function my_key_bindings
  fish_default_key_bindings -M insert
  fish_vi_key_bindings
  bind -M insert -m default jk force-repaint
  bind -M visual -m default jk force-repaint
end
set -g fish_key_bindings my_key_bindings
