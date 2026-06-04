##################
##### CONFIG #####
##################

## 1. Zsh
## 1.1 历史记录大小
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
## 1.2 在历史记录中添加时间戳
setopt EXTENDED_HISTORY
## 1.3 允许无需输入 cd 即可切换目录
setopt autocd
## 1.4 初始化 Zsh 自动补全系统
autoload -U compinit; compinit
## 1.5 启动 Starship
eval "$(starship init zsh)"
## 1.6 启动 fzf
source <(fzf --zsh)
## 1.7 启动 zoxide
eval "$(zoxide init zsh --cmd cd)"

#################
##### ALIAS #####
#################

## 1. trash
alias del='/opt/homebrew/Cellar/trash/0.9.2/bin/trash -F '
## 2. pbcopy
alias cp='pbcopy'
## 3. eza
## 3.1 默认显示 icons：
alias ls="eza --icons"
## 3.2 显示文件目录详情
alias ll="eza --icons --long --header"
## 3.3 显示全部文件目录，包括隐藏文件
alias la="eza --icons --long --header --all"
## 3.4 显示详情的同时，附带 git 状态信息
alias lg="eza --icons --long --header --all --git"
## 3.5 zoxide
alias z='cd'



#######################
##### ENVIRONMENT #####
#######################

## 1. local binary
export PATH="/Users/lijc/.local/bin:$PATH"  # Added by Deck.app
## 2. homebrew binary
export PATH="/opt/homebrew/bin:$PATH"
## 3. llvm
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"

####################
##### FUNCTION #####
####################

startEasyConnect() {
    /Applications/EasyConnect.app/Contents/Resources/bin/EasyMonitor > /dev/null 2>&1 &
    /Applications/EasyConnect.app/Contents/MacOS/EasyConnect > /dev/null 2>&1 &
}

fuckEasyConnect() {
    function killprocess()
    {
        processname=$1
        killall $processname >/dev/null 2>&1
        proxypids=$(ps aux | grep -v grep | grep $processname | awk '{print $2}')
        for proxypid in $proxypids
        do
            kill -9 $proxypid
        done
    }

    killprocess svpnservice
    killprocess CSClient
    killprocess ECAgentProxy
    killprocess /Applications/EasyConnect.app/Contents/MacOS/EasyConnect

    pkill ECAgent
    pkill EasyMonitor
}

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

zx() {
  local query="${*}"
  local dir

  dir=$(zoxide query --list --score | \
    fzf --filter="$query" --no-sort | \
    fzf \
      --prompt="zoxide > " \
      --nth=2.. \
      --ansi \
      --height=60% \
      --info=inline \
      --border=rounded \
      --layout=reverse \
      --preview-window=down:40%:wrap \
      --preview='ls -F -C --color=always {2..}' \
   --bind 'ctrl-z:ignore,btab:up,tab:down,enter:become:echo {2..}' \
      --cycle \
      --keep-right \
      --tabstop=1
  )

  [[ -n "$dir" ]] && cd "$dir"
}
