# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#----------------------------------------------------------------------#
# Prompt
#----------------------------------------------------------------------#

# Colors
COLC="\[\033[0;36m\]" # Cyan
COLB="\[\033[0;34m\]" # Blue
COLP="\[\033[0;35m\]" # Purple
COLR="\[\033[0;31m\]" # Red
COLN="\[\033[0m\]"	  # Reset

# Default color to use
COL="$COLC"
[[ "$UID" = "0" ]] && COL=$COLR	# Use red for root

function __promptadd
{
	XTITLE='\[\e]0;\s (\w)\a\]'
    PS1="$XTITLE$PS1\n$COL \\$ $COLN"
}

function prompt_line
{
    source ~/.shell_prompt.sh
    PROMPT_COMMAND="$PROMPT_COMMAND __promptadd;"
}

# Normal prompt
function prompt_term
{
	# Git options 
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"

    # Prompt final
	PROMPT_COMMAND=""
    PS1="$COLV--[$COLC\h$COLV]-[$COLA\w$COLV]\$(__git_ps1)\n$COL \\$ $COLN"
}

# Use custom shell prompt
case "$COLORTERM" in
  rxvt*)
	  prompt_line
    ;;
  *)
	  prompt_term
    ;;
esac


#----------------------------------------------------------------------#
# Color
#----------------------------------------------------------------------#

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	export LS_OPTIONS='--color=auto'
	alias l='ls $LS_OPTIONS'
	alias ll='ls $LS_OPTIONS -l -N -F'
	alias ls='ls $LS_OPTIONS -A -N -hF'
fi

export GREP_COLOR="1;31"
alias grep='grep --color=auto'
export LESS="-R"

#----------------------------------------------------------------------#
# PATH
#----------------------------------------------------------------------#
export PATH="$PATH:$HOME/bin"

#----------------------------------------------------------------------#
# Variables 
#----------------------------------------------------------------------#

# Defaults
export EDITOR="vim"
export BROWSER="chromium"

#----------------------------------------------------------------------#
# Alias
#----------------------------------------------------------------------#

# Auto-completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

# Extract utilities
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjvf $1    ;;
        *.tar.gz)    tar xzvf $1    ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xvf $1     ;;
        *.tbz2)      tar xjvf $1    ;;
        *.tgz)       tar xzvf $1    ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

if [ $TERM = vt100 ]; then
  alias ls='ls -F --color=never';
fi

#----------------------------------------------------------------------#
# SSH KEY
#----------------------------------------------------------------------#

# Init ssg-agent if not exist
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s` &> /dev/null
fi

# attempt to connect to a running agent, sharing over sessions 
check-ssh-agent() {
    [ -S "$SSH_AUTH_SOCK" ] && { ssh-add -l >& /dev/null || [ $? -ne 2 ]; }
}

check-ssh-agent || export SSH_AUTH_SOCK=/tmp/ssh-agent.sock_$USER
check-ssh-agent || eval "$(ssh-agent -s -a /tmp/ssh-agent.sock_$USER)" > /dev/null

#Add identities if not exist
if [[ -n $(ssh-add -l | grep 'The agent has no identities') ]] ; then
  ssh-add 2> /dev/null
fi

