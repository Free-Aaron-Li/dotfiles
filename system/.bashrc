# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	#alias grep='grep --color=auto'
	#alias fgrep='fgrep --color=auto'
	#alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
# Set LS_COLORS environment by Deepin
if [[ ("$TERM" = *256color || "$TERM" = screen* || "$TERM" = xterm*) && -f /etc/lscolor-256color ]]; then
	eval $(dircolors -b /etc/lscolor-256color)
else
	eval $(dircolors)
fi

###########################
########## ALIAS ##########
###########################
##
## Delete Files
##
alias del='trash-put'

##
## Show Files
alias ls='lsd'

##
## Neovide
##
alias vide='neovide'

##
## Fix File name
##
alias fn='/home/aaron/.files/script/fix_filename.sh'

##
## Zen Browser
##
alias zen='/opt/apps/app.zen-browser/files/AppRun'

##
## All list
##
alias lsa='ls -ahil'

##
## grep
##
alias grep='grep --color=auto --extended-regexp'

##
## Interactively copy and move
##
alias cp='cp --interactive'
alias mv='mv --interactive'

###########################
####### ENVIRONMENT #######
###########################
##
## 0. Bin
##
export PATH=$HOME/.local/bin/:$PATH

##
## 1. Anaconda
##
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/environment/anaconda3/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
	eval "$__conda_setup"
else
	if [ -f "$HOME/environment/anaconda3/etc/profile.d/conda.sh" ]; then
		. "$HOME/environment/anaconda3/etc/profile.d/conda.sh"
	else
		export PATH="$HOME/environment/anaconda3/bin:$PATH"
	fi
fi
unset __conda_setup
# <<< conda initialize <<<

##
## 2. Superfile
##
spf() {
	os=$(uname -s)

	# Linux
	if [[ "$os" == "Linux" ]]; then
		export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
	fi

	# macOS
	if [[ "$os" == "Darwin" ]]; then
		export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
	fi

	command spf "$@"

	[ ! -f "$SPF_LAST_DIR" ] || {
		. "$SPF_LAST_DIR"
		rm -f -- "$SPF_LAST_DIR" >/dev/null
	}
}

##
## 3. Qt
##
export QTDIR=$HOME/environment/Qt/6.9.0/
export PATH=$HOME/environment/Qt/6.9.0/gcc_64:$PATH
export PATH=$HOME/environment/Qt/6.9.0/gcc_64/bin:$PATH
export QT_QPA_PLATFORM=xcb

# 解决：KMS: DRM_IOCTL_MODE_CREATE_DUMB failed
# readest 应用问题
export WEBKIT_DISABLE_DMABUF_RENDERER=1

##
## 4. NVM
##
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

##
## 5. bin
##
export PATH="$HOME/.local/share/../bin:$PATH"

##
## 6. JDK
##
export JAVA_HOME=$HOME/environment/jdk
export PATH=$JAVA_HOME/bin:$PATH

##
## 7. Flutter
##
export FLUTTER_HOME=$HOME/environment/flutter
export PATH=$FLUTTER_HOME/bin:$PATH
## 7.1 Flutter Pub 源
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
## 7.2 Dart
export PATH=$PATH:$HOME/environment/flutter/bin

##
## 8. Android
##
export ANDROID_HOME=$HOME/environment/Android/Sdk
export PATH=$ANDROID_HOME:$PATH
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/build-tools/34.0.0
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/ndk
export PATH=$PATH:$ANDROID_HOME/platform-tools

##
## 9. C/C++ Toolkit
##
export CC=$HOME/environment/gcc-15.1.0/bin/gcc
export CXX=$HOME/environment/gcc-15.1.0/bin/g++
export MY_GCC=$HOME/environment/gcc-15.1.0/
export LD_LIBRARY_PATH="/home/aaron/environment/gcc-15.1.0/lib64:$LD_LIBRARY_PATH"
export MY_GLIBC=$HOME/environment/glibc
export PATH="/home/aaron/environment/gdb-16.3/bin:$PATH"

##
## 10. LLVM
##
export PATH=$HOME/environment/LLVM-20.1.3-Linux-X64/bin:$PATH

##
## 11. Neovim
##
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

##
## 12. Go
##
export GOROOT=/home/aaron/environment/go
export PATH="$PATH:$GOROOT/bin"
export GOPATH=$HOME/go/lib:$HOME/go/work
