# ~/.bashrc
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
source /usr/share/git/completion/git-prompt.sh

PS1='\[\e[0;36m\]\u\[\e[m\]@\[\033[00;32m\]\h\[\033[00;37m\]:\[\033[31m\]$(__git_ps1 "(%s)\[\033[01m\]")\[\033[0;34m\]\w\[\033[00m\] $ '
