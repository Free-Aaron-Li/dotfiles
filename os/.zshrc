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
## 1.8 Homebrew GCC 16
export CC=/opt/homebrew/bin/gcc-16
export CXX=/opt/homebrew/bin/g++-16
## 1.9 cmkae 默认生成 compile_commands.json
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
## 1.10 vcpkg 默认使用gcc编译，并需要配置 triplets 和 toolchains
export VCPKG_DEFAULT_TRIPLET=arm64-osx-gcc16
export VCPKG_OVERLAY_TRIPLETS="$HOME/.vcpkg-overlay-triplets"
## 1.11 Qt
export QT_ROOT="$HOME/env/qt/6.11.2/macos"


#################
##### ALIAS #####
#################

## 1. trash
alias del='/opt/homebrew/Cellar/trash/0.9.2/bin/trash -F '
## 2. pbcopy
alias cy='pbcopy'
## 3. eza
## 3.1 默认显示 icons：
alias ls="eza --icons"
## 3.2 显示文件目录详情
alias ll="eza --icons --long --header"
## 3.3 显示全部文件目录，包括隐藏文件
alias la="eza --icons --long --header --all"
## 3.4 显示详情的同时，附带 git 状态信息
alias lg="eza --icons --long --header --all --git"
## 4. zoxide
alias z='cd'
## 5. no noise
alias nn='sudo xattr -cr '
## 6. open awesome-cpp web
alias ac0='open /Users/lijc/source/cpp/awesome-cpp/doxygen/html/index.html'
alias ac1='open /Users/lijc/source/qt/ecas/doxygen/html/index.html'
## 7. copy source
alias copy_source='~/.files/script/copy_source.sh'
## 8. tre
alias tree='tre'


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
## 4. java
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export JAVA_HOME="/opt/homebrew/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

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

function yz() {
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

git-remote-ssh() {
    local script="$HOME/.files/script/git_remote_http_to_ssh.sh"

    if [[ ! -x "$script" ]]; then
        echo "错误：脚本 $script 不存在或不可执行" >&2
        echo "请确保已保存并赋予执行权限。" >&2
        return 1
    fi

    # 将传给函数的所有参数原样传递给脚本
    "$script" "$@"
}

# 启动 IoTDB（后台运行）
iotdb-start() {
    if [ -z "$IOTDB_HOME" ]; then
        echo "错误: 请先设置 IOTDB_HOME 环境变量"
        return 1
    fi
    if lsof -i :6667 > /dev/null 2>&1; then
        echo "IoTDB 已经在运行中（端口 6667 已监听）"
        return 0
    fi
    echo "正在启动 IoTDB ..."
    nohup "$IOTDB_HOME/sbin/start-standalone.sh" > "$IOTDB_HOME/logs/startup.log" 2>&1 &
    local waited=0
    local max_wait=30   # 增加到 30 秒
    while [ $waited -lt $max_wait ]; do
        sleep 1
        waited=$((waited + 1))
        if lsof -i :6667 > /dev/null 2>&1; then
            echo "IoTDB 启动成功（端口 6667 已监听）"
            return 0
        fi
        # 每 5 秒输出一个点，表示等待中
        if [ $((waited % 5)) -eq 0 ]; then
            echo -n "."
        fi
    done
    echo ""
    echo "启动超时（${max_wait}秒），请检查以下日志："
    echo "  - $IOTDB_HOME/logs/startup.log"
    echo "  - $IOTDB_HOME/logs/confignode.log"
    echo "  - $IOTDB_HOME/logs/datanode.log"
    return 1
}

# 停止 IoTDB
iotdb-stop() {
    if [ -z "$IOTDB_HOME" ]; then
        echo "错误: 请先设置 IOTDB_HOME 环境变量"
        return 1
    fi
    if ! lsof -i :6667 > /dev/null 2>&1; then
        echo "IoTDB 未在运行"
        return 0
    fi
    echo "正在停止 IoTDB ..."
    "$IOTDB_HOME/sbin/stop-standalone.sh"
    sleep 2
    if lsof -i :6667 > /dev/null 2>&1; then
        echo "停止失败，尝试强制终止..."
        pkill -f "org.apache.iotdb.db.service.DataNode" 2>/dev/null
        pkill -f "org.apache.iotdb.confignode.service.ConfigNode" 2>/dev/null
        sleep 1
        if lsof -i :6667 > /dev/null 2>&1; then
            echo "强制终止后端口仍被占用，请手动处理"
        else
            echo "IoTDB 已成功停止"
        fi
    else
        echo "IoTDB 已停止"
    fi
}

# 查看 IoTDB 状态
iotdb-status() {
    if lsof -i :6667 > /dev/null 2>&1; then
        echo "IoTDB 正在运行（端口 6667 已监听）"
    else
        echo "IoTDB 未运行"
    fi
}

# 重启 IoTDB（等待端口彻底释放，并额外延迟）
iotdb-restart() {
    iotdb-stop
    echo "等待端口释放..."
    local waited=0
    while [ $waited -lt 10 ]; do
        if ! lsof -i :6667 > /dev/null 2>&1; then
            echo "端口已释放"
            break
        fi
        sleep 1
        waited=$((waited + 1))
    done
    if [ $waited -ge 10 ]; then
        echo "警告: 端口 6667 在 10 秒后仍未释放，强制继续..."
    fi
    # 额外等待 2 秒确保系统稳定
    sleep 2
    iotdb-start
}


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# EasyTier 管理函数
# 请根据你的实际路径修改下面的变量
EASYTIER_BIN="/Users/lijc/Applications/easytier/easytier-core"
EASYTIER_CONFIG="/Users/lijc/backup/easytier/mac-config.toml"
EASYTIER_PIDFILE="/tmp/easytier.pid"
EASYTIER_LOGFILE="/tmp/easytier.log"

# 启动 EasyTier（后台运行）
function easytier-start() {
    if [[ -f "$EASYTIER_PIDFILE" ]] && kill -0 $(cat "$EASYTIER_PIDFILE") 2>/dev/null; then
        echo "EasyTier 已经在运行 (PID: $(cat $EASYTIER_PIDFILE))"
        return 1
    fi
    echo "正在启动 EasyTier ..."
    sudo nohup "$EASYTIER_BIN" -c "$EASYTIER_CONFIG" >> "$EASYTIER_LOGFILE" 2>&1 &
    local pid=$!
    echo $pid | sudo tee "$EASYTIER_PIDFILE" > /dev/null
    echo "EasyTier 已启动，PID: $pid"
    echo "日志文件: $EASYTIER_LOGFILE"
}

# 停止 EasyTier
function easytier-stop() {
    if [[ ! -f "$EASYTIER_PIDFILE" ]]; then
        echo "PID 文件不存在，尝试用 pkill ..."
        sudo pkill -f "$EASYTIER_BIN"
        return
    fi
    local pid=$(cat "$EASYTIER_PIDFILE")
    if kill -0 $pid 2>/dev/null; then
        echo "正在停止 EasyTier (PID: $pid)..."
        sudo kill -TERM $pid
        # 等待进程结束
        while kill -0 $pid 2>/dev/null; do sleep 1; done
        sudo rm -f "$EASYTIER_PIDFILE"
        echo "已停止"
    else
        echo "进程 $pid 不存在，清理 PID 文件"
        sudo rm -f "$EASYTIER_PIDFILE"
    fi
}

# 查看 EasyTier 状态
function easytier-status() {
    if [[ -f "$EASYTIER_PIDFILE" ]]; then
        local pid=$(cat "$EASYTIER_PIDFILE")
        if kill -0 $pid 2>/dev/null; then
            echo "✅ EasyTier 正在运行"
            echo "   PID: $pid"
            echo "   监听端口:"
            sudo lsof -i -P | grep -E "$pid|easytier" | grep LISTEN || echo "   未检测到监听端口（可能未绑定）"
            echo "   日志: $EASYTIER_LOGFILE"
        else
            echo "❌ PID 文件存在但进程已死，建议执行 easytier-stop 清理"
        fi
    else
        # 尝试用 pgrep 查找
        local pids=$(pgrep -f "$EASYTIER_BIN")
        if [[ -n "$pids" ]]; then
            echo "⚠️ 有 EasyTier 进程在运行但 PID 文件丢失: $pids"
        else
            echo "❌ EasyTier 未运行"
        fi
    fi
}

# 查看实时日志
function easytier-logs() {
    if [[ -f "$EASYTIER_LOGFILE" ]]; then
        tail -f "$EASYTIER_LOGFILE"
    else
        echo "日志文件不存在: $EASYTIER_LOGFILE"
    fi
}

# 重启 EasyTier
function easytier-restart() {
    easytier-stop
    sleep 1
    easytier-start
}
