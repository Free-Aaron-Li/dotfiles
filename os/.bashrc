# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

#export LIBVA_DRIVER_NAME=nvidia

#----------
# 1. 环境变量
#----------

# 1. Drogon
export PATH="/home/leorio/environment/drogon/bin:$PATH"

# 2. superfile
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

# 3. local bin
export PATH="/home/leorio/.local/bin:$PATH"

# 4. Qt
# 严重警告⚠️：在fedora43中这样做会污染环境，请不要设置全局配置，仅需在IDE中配置即可。
#export QT_QPA_PLATFORM=xcb
#export QT_HOME=/home/leorio/environment/qt/6.10.1/gcc_64
#export QT6_DIR=QT_HOME
#export PATH=$QT_HOME/bin:$PATH
#export CMAKE_PREFIX_PATH=$QT_HOME:$CMAKE_PREFIX_PATH
#export LD_LIBRARY_PATH=$QT_HOME/lib:$LD_LIBRARY_PATH
#export QTDIR=$QT_HOME
#export QT_PLUGIN_PATH=$QT_HOME/plugins
#export QML_IMPORT_PATH=$QT_HOME/qml
#export QML2_IMPORT_PATH=$QT_HOME/qml
#export QT_QPA_PLATFORM=xcb

# 5. Work Env path
export myenv=/home/leorio/environment
export mysrc=/home/leorio/source
export mydl=/home/leorio/Downloads

# 6. Zoxide
export _ZO_DOCTOR=0

# 7. cuda-toolkit
export PATH="/usr/local/cuda-13.1/bin:$PATH"

# 8. PlatformIO
export PATH=/home/leorio/.platformio/penv/bin:$PATH

# 9. NPM
export PATH=~/.npm-global/bin:$PATH

#----------
# 2. 别名
#----------

# 1. Neovim & Nevide
alias nv='neovide'    # nvim

# 2. Delete
alias del='trash-put' # trash

# 3. eza
# 3.1 默认显示 icons：
alias ls="eza --icons"
# 3.2 显示文件目录详情
alias ll="eza --icons --long --header"
# 3.3 显示全部文件目录，包括隐藏文件
alias la="eza --icons --long --header --all"
# 3.4 显示详情的同时，附带 git 状态信息
alias lg="eza --icons --long --header --all --git"
# 3.5 替换 tree 命令
alias tree="eza --tree --icons"

# 4. Mariadb
alias mariadb="sudo docker exec -it mariadb mariadb -u root -p"

# 5. 复制至剪贴板
alias xc="xclip -selection clipboard"

# 6. 回收站
alias del=trash-put

# 7. open
alias open=xdg-open



#----------
# 3. 启动项
#----------

# 1. 关闭蜂鸣
#xset b off

# 2. zoxide
eval "$(zoxide init bash)"

# 3.xmake

# >>> xmake >>>
test -f "/home/leorio/.xmake/profile" && source "/home/leorio/.xmake/profile"
# <<< xmake <<<

# opencode
export PATH=/home/leorio/.opencode/bin:$PATH

# pnpm
export PNPM_HOME="/home/leorio/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# OpenClaw Completion
source "/home/leorio/.openclaw/completions/openclaw.bash"
