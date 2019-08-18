# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#-------------------------------------------------------------------------------
# FUNCTIONS
#-------------------------------------------------------------------------------

function get_xserver()
{
    case $TERM in
        xterm )
        XSERVER=$(whoami | awk '{print $NF}' | tr -d ')''(' )
        # Ane-Pieter Wieringa suggests the following alternative:
        #  I_AM=$(who am i)
        #  SERVER=${I_AM#*(}
        #  SERVER=${SERVER%*)}
        XSERVER=${XSERVER%%:*}
        ;;
        aterm | rxvt)
        # Find some code that works here. ...
        ;;
    esac
}

function git_status()
{
    untracked=$(git status | grep 'Untracked files' 2> /dev/null)
    if [[ -n "$untracked" ]] ; then
        echo "☢"
    fi

    to_commit=$(git status | grep 'Changes not staged for commit' 2> /dev/null)
    if [[ -n "$to_commit" ]] ; then
        echo "☠"
    fi

    is_ahead=$(git status | grep 'Your branch is ahead of' 2> /dev/null)
    if [[ -n "$is_ahead" ]] ; then
        echo "⇧"
    else
        is_behind=$(git status | grep 'Your branch is behind' 2> /dev/null)
        if [[ -n "$is_behind" ]] ; then
        echo "⇩"
        fi
    fi
}

function parse_git_branch ()
{
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
    if [[ -n "$branch" ]] ; then
        echo $branch$(git_status)
    fi
}

# Handy Extract Program. Extracts 'Here'
# ToDo: Add 2nd param for destination folder
function extract()
{
    if [[ -f $1 ]] ; then
        case $1 in
        *.tar.bz2)   tar xvjf $1     ;;
        *.tar.gz)    tar xvzf $1     ;;
        *.tar.xz)    tar xvxf $1     ;;
        *.bz2)       bunzip2 $1      ;;
        *.rar)       unrar x $1      ;;
        *.gz)        gunzip $1       ;;
        *.tar)       tar xvf $1      ;;
        *.tbz2)      tar xvjf $1     ;;
        *.tgz)       tar xvzf $1     ;;
        *.zip)       unzip $1        ;;
        *.Z)         uncompress $1   ;;
        *.7z)        7z x $1         ;;
        *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Get IP adress on ethernet.
function my_ip()
{
    MY_IP=$(/sbin/ifconfig wlp7s0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

# Get current host related info.
function ii()
{
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs | cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
    echo -e "\n${BRed}Diskspace :$NC " ; pydf / $HOME
    echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}

# Function to run upon exit of shell.
function _exit()
{
    echo -e "${BRed}Hasta la vista, baby${NC}"
    sleep 1
}
trap _exit EXIT

NCPU=$(grep -c 'processor' /proc/cpuinfo)    # Number of CPUs
SLOAD=$(( 100*${NCPU} ))        # Small load
MLOAD=$(( 200*${NCPU} ))        # Medium load
XLOAD=$(( 400*${NCPU} ))        # Xlarge load
  
# Returns a color indicating system load.
function load_color()
{
    local SYSLOAD=$(load)
    if [[ ${SYSLOAD} -gt ${XLOAD} ]] ; then
        echo -en ${ALERT}
    elif [[ ${SYSLOAD} -gt ${MLOAD} ]] ; then
        echo -en ${Red}
    elif [[ ${SYSLOAD} -gt ${SLOAD} ]] ; then
        echo -en ${BRed}
    else
        echo -en ${Green}
    fi
}

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color according to free disk space in $PWD.
function disk_color()
{
    if [[ ! -w "${PWD}" ]] ; then
        echo -en ${Red}
        # No 'write' privilege in the current directory.
    elif [ -s "${PWD}" ] ; then
        local used=$(command df -P "$PWD" |
                awk 'END {print $5} {sub(/%/,"")}')
        if [ ${used} -gt 95 ]; then
        echo -en ${ALERT}           # Disk almost full (>95%).
        elif [ ${used} -gt 90 ]; then
        echo -en ${BRed}            # Free disk space almost gone.
        else
        echo -en ${Green}           # Free disk space is ok.
        fi
    else
        echo -en ${Cyan}
        # Current directory is size '0' (like /proc, /sys etc).
    fi
}

# Returns a color according to running/suspended jobs.
function job_color()
{
    if [ $(jobs -s | wc -l) -gt "0" ]; then
        echo -en ${BRed}
    elif [ $(jobs -r | wc -l) -gt "0" ] ; then
        echo -en ${BCyan}
    fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar()
{
    tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; 
}

# Create a ZIP archive of a file or folder.
function makezip() 
{ 
    zip -r "${1%%/}.zip" "$1" ; 
}

# Make your directories and files access rights sane. (750)
function sanitize()
{ 
    chmod -R u=rwX,g=rX,o= "$@" ;
}

# Copy and go to dir
function cpg()
{
    if [ -d "$2" ];then
        cp $1 $2 && cd $2
    else
        cp $1 $2
    fi
}

# Move and go to dir
function mvg()
{
    if [ -d "$2" ];then
        mv $1 $2 && cd $2
    else
        mv $1 $2
    fi
}

# Create and go to dir
function mkg()
{
    mkdir $1 && cd $1
}

# Search for running process
function psgrep()
{
	if [ ! -z $1 ] ; then
		echo "Grepping for processes matching '$1'..."
		ps aux | grep $1 | grep -v grep
	else
		echo "!! Need name to grep for"
	fi
}

# Take ownership
function grab()
{
	sudo chown -R ${USER} ${1:-.}
}

# The weather, because why not?
function ttr()
{
  curl -H "Accept-Language: ${LANG%_*}" wttr.in/?0
}

# Are we online?
function conntest()
{
  wget -q --spider http://google.com

  if [ $? -eq 0 ]; then
      return 0
  else
      return 1
  fi
}

# Nerd-radio
function radio()
{
    if [[ ! -x /usr/bin/mplayer ]] ; then
        sudo apt install mplayer
    fi

    radio=''
    case $1 in
        ('1977')        radio='http://67.222.24.62:9330/' ;;
        ('azul')        radio='http://195.154.182.222:3320/stream' ;;
        ('babel')       radio='http://radiosrnu.com:9340/stream' ;;
        ('bandit')      radio='http://fm02-icecast.mtg-r.net/fm02_mp3?platform=web' ;;
        ('delsol')      radio='http://radio.dl.uy:9950/radio' ;;
        ('disney')      radio='http://streamrd1.sarandi.com.uy:9350/' ;;
        ('espectador')  radio='http://espectador1.net.com.uy:8120/stream/' ;;
        ('futurock')    radio='http://radio1.us.mediastre.am/futurockargentina.aac' ;;
        ('galaxia')     radio='http://streamingraddios.net:10312' ;;
        ('lacosta')     radio='http://195.154.182.222:27126/stream' ;;
        ('latina')      radio='http://206.190.133.196:7034' ;;
        ('oceano')      radio='http://radio3.oceanofm.com:8010/' ;;
        ('kexp')        radio='https://kexp-mp3-128.streamguys1.com/kexp128.mp3' ;;
        ('lista'|'')    listRadios ;;
        *)              radio=$1 ;;
    esac

    if [[ ! $1 == 'lista' ]] ; then
        mplayer $radio
    fi
}

function listRadios()
{
                 echo "    1977      - 1977 Radio"
    sleep 0.1 && echo "    azul      - Azul 101.9"
    sleep 0.1 && echo "    babel     - Babel 97.1"
    sleep 0.1 && echo "    bandit    - Bandit Rock, Stockholm"
    sleep 0.1 && echo "    delsol    - Del Sol 99.5"
    sleep 0.1 && echo "    disney    - Radio Disney Uruguay 91.9"
    sleep 0.1 && echo "    espectador- El Espectador Uruguay 810 AM"
    sleep 0.1 && echo "    futurock  - Futuröck Argentina futurock.fm"
    sleep 0.1 && echo "    galaxia   - Emisora Galaxia 105.9"
    sleep 0.1 && echo "    kexp      - KEXP"
    sleep 0.1 && echo "    lacosta   - La Costa FM 88.3"
    sleep 0.1 && echo "    latina    - Latina FM 103.7"
    sleep 0.1 && echo "    oceano    - Oceano FM 93.9"
}

function detail()
{
    if [[ $# -eq 0 ]] ; then
        echo "Must pass a parameter"
    elif [[ $# -ne 1 ]] ; then
        echo "Must pass only one parameter"
    elif [[ ! -e $1 ]] ; then
        echo "Parameter must be a valid file path"
    else
        size=$(stat -c %s "$1" | numfmt --to=iec)
        stat --printf "\n\e[1;33m%n\e[m\nSize:   $size\nAccess: %a (%A)\nOwner:  %U\nGroup:  %G\n" $1
    fi 
}

function setenv()
{
	if [[ $# -ne 2 ]] ; then
		echo "setenv: Too few arguments"
	else
		export $1="$2"
	fi
}

#-------------------------------------------------------------------------------
# GREETINGS, STYLES
#-------------------------------------------------------------------------------

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

ALERT=${BWhite}${On_Red} # Bold White on red background

echo -e "${BGreen}This is BASH ${BRed}${BASH_VERSION%.*}${NC}\n"
date
if [[ -x /usr/games/fortune ]]; then
    if [[ -x /usr/games/cowsay ]]; then 
      /usr/games/fortune -s | /usr/games/cowsay     # Makes our day a bit more fun.... :-)
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    else
      echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      /usr/games/fortune -s     # Makes our day a bit more fun.... :-)
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    fi
fi

cal
echo -e "\n"

#-------------------------------------------------------------------------------
# SETTINGS
#-------------------------------------------------------------------------------

if [ -z ${DISPLAY:=""} ]; then
    get_xserver
    if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) ||
       ${XSERVER} == "unix" ]]; then
          DISPLAY=":0.0"          # Display on local host.
    else
       DISPLAY=${XSERVER}:0.0     # Display on remote host.
    fi
fi

export DISPLAY

# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${Green}        # Connected on remote machine, via ssh (good).
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${ALERT}        # Connected on remote machine, not via ssh (bad).
else
    CNX=${BCyan}        # Connected on local machine.
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Red}           # User is root.
elif [[ ${USER} != $(logname) ]]; then
    SU=${BRed}          # User is not login user.
else
    SU=${BCyan}         # User is normal (well ... most of us are).
fi

# Don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth
export HISTCONTROL=ignoredups
# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# Check the window size after each command and, if necessary,
# Update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# The PS1 itself
if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\e[93m $(parse_git_branch)\e[39m\n\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

#-------------------------------------------------------------------------------
# ALIASES
#-------------------------------------------------------------------------------

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

alias svim='sudo vim'
alias cim='vim'
alias root='sudo su'

# Directory navigation aliases
alias back='cd $OLDPWD'
alias h='cd'
alias cd..='cd ..'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Set Git language to English
alias git='LANG=en_US git'
#alias git='LANG=en_GB git'

# Select php-cli version ON / OFF to 5.6
# alias php=/usr/bin/php5.6
# alias php=/usr/bin/php7.1
# alias php=/usr/bin/php7.2
# alias php=/usr/bin/php7.3

alias h='history'
alias hgrep='history | grep'
alias j='jobs -l'
alias which='type -a'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

# Handy permission number print
alias perm='stat -c "%a"'
alias permission=perm
alias permhere='find . -type d -exec stat -c "%a - %n" '{}' \;'
#alias detail SEE FUNCTION detail

#-------------------------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------------------------

# Add colors for filetype and  human-readable sizes by default on 'ls':
alias l='ls -CF'
alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lvF --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

# System alias
alias install='sudo apt install'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias purge='sudo apt purge'
alias autoremove='sudo apt autoremove'

# Ask nicely
alias please='sudo $(fc -ln -1)'

# The typo family (highly personal)
alias hisotry='history'
alias cim='vim'
alias got='git'

# External alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export GOPATH=$HOME/go

# PATH concatenation. Some extra scripts are stored in ~/.bin
PATH=$PATH:$HOME/.bin:$HOME/.composer/vendor/bin:$GOROOT/bin:$GOPATH/bin
