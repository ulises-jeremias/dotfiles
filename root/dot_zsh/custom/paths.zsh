# custom bin directory
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# emacs bin dir
PATH="$HOME/.emacs.d/bin:$PATH"

# ld
LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}"

# yarn and fnm
PATH="$(yarn global bin):$PATH"
PATH="$HOME/.local/share/fnm:$HOME/.fnm:$PATH"
eval "$(fnm env)"

# Golang
PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

eval "$(direnv hook zsh)"

export LD_LIBRARY_PATH PATH GOPATH GOROOT
