# add ~/bin to path if it exists and is not already in path
[[ -d "$HOME/bin" && ! "$PATH" =~ "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"

# add ~/.local/bin to path if it exists and is not already in path
[[ -d "$HOME/.local/bin" && ! "$PATH" =~ "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"

# add ~/.emacs.d/bin to path if it exists and is not already in path
[[ -d "$HOME/.emacs.d/bin" && ! "$PATH" =~ "$HOME/.emacs.d/bin" ]] && PATH="$HOME/.emacs.d/bin:$PATH"

# add yarn global bin to path if it exists and is not already in path
YARN_GLOBAL_BIN="$(yarn global bin)"
[[ -d "$YARN_GLOBAL_BIN" && ! "$PATH" =~ "$YARN_GLOBAL_BIN" ]] && PATH="$YARN_GLOBAL_BIN:$PATH"

# add fnm directory to path if it exists and is not already in path
FNM_DIR="$HOME/.local/share/fnm"
[[ -d "$FNM_DIR" && ! "$PATH" =~ "$FNM_DIR" ]] && PATH="$FNM_DIR:$PATH"

# add fnm directory to path if it exists and is not already in path
FNM_DIR="$HOME/.fnm"
[[ -d "$FNM_DIR" && ! "$PATH" =~ "$FNM_DIR" ]] && PATH="$FNM_DIR:$PATH"

# eval fnm env
eval "$(fnm env)"

# add pyenv directory to path if it exists and is not already in path
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Add go bin to path
PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

# Setup direnv
eval "$(direnv hook zsh)"

# Setup rbenv
eval "$(rbenv init - zsh)"

export LD_LIBRARY_PATH PATH GOPATH GOROOT
