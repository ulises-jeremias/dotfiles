# Shell-GPT integration for ZSH
_sgpt_zsh() {
	if [[ -n "$BUFFER" ]]; then
		_sgpt_prev_cmd=$BUFFER
		BUFFER+="   "
		zle -I && zle redisplay
		BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
		zle end-of-line
	fi
}
zle -N _sgpt_zsh
bindkey "^p" _sgpt_zsh
