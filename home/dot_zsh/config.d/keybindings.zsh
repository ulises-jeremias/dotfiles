# Key Bindings
#-------------------------------------------------------------------------------
# Set vi-mode and create a few additional Vim-like mappings
#-------------------------------------------------------------------------------
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
#

# bindkey
bindkey "^U" backward-kill-line
bindkey "^u" backward-kill-line
bindkey "^[l" down-case-word
bindkey "^[L" down-case-word

# ctrl+<- | ctrl+->
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
