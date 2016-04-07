alias more='less'
alias df='df -h'
alias du='du -c -h'
alias c='clear'
alias path='echo -e ${PATH//:/\\n}'
alias cat='/system/bin/cat'

alias l=ls
alias ls='ls -hF --color=auto'
alias lr='ls -R'    # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -X'    # sort by extension
alias lz='ll -rS'   # sort by size
alias lt='ll -rt'   # sort by date
alias lm='la | more'

[[ $PATH == */system/busybox* ]] || export PATH=/system/busybox:$PATH
export PS1='$USER@$HOSTNAME:${PWD:-?} $ '
export PS2='> '
export TERMINFO=/system/etc/terminfo
export TERM=linux

HISTFILE=$EXTERNAL_STORAGE/.shell_history

if [ -f $EXTERNAL_STORAGE/.shellrc ]; then
    source $EXTERNAL_STORAGE/.shellrc
fi
