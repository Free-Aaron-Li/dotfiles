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
## 1.12 deepseek harness
# 密钥外置到加密卷（2026-09-10，规则见 ~/.agents/skills/secrets-keys-volume）
[ -r /Volumes/keys/dsh/shell-secrets.env ] && source /Volumes/keys/dsh/shell-secrets.env
## 1.13 pip venv
source /Users/lijc/env/.venv/bin/activate
export PATH=/Users/lijc/env/.venv/bin:$PATH
## 1.14 clash verge
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897
export NODE_USE_ENV_PROXY=1


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
alias ac1='open /Users/lijc/env/harness/doxygen/html/index.html'
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
## 5. pnpm
# pnpm
export PNPM_HOME="/Users/lijc/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
## 6. easytier
export PATH="/Users/lijc/Applications/easytier:$PATH"

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

##########################################################
# Hindsight 本地 daemon LLM 配置（DeepSeek）——2026-08-30 配置
export HINDSIGHT_API_LLM_PROVIDER=deepseek

##########################################################
# 在 ~/.zshrc 中定义虚拟环境路径（根据你的实际路径修改）
# 这里假设你的虚拟环境在 $HOME/env/.venv （绝对路径）
# 如果你的路径不同，请修改下面的 DSH_VENV_PATH
DSH_VENV_PATH="$HOME/env/.venv"   # 例如 /Users/lijc/env/.venv

# ============================================================
# dsh web 托管：launchd LaunchAgent（com.user.dsh-web）——2026-09-04
# 背景：旧 dp-start 用 nohup & 从终端启动，ghostty 退出即带走 harness
#      （nohup 防不住 dsh 派生的 node 子进程 SIGHUP）。
# 现方案：launchd 完全后台托管 + KeepAlive 崩溃自启，脱离一切终端。
# plist: ~/Library/LaunchAgents/com.user.dsh-web.plist
# 包装:  ~/.local/bin/dsh-web.sh（日志 /tmp/dsh-web.log）
DSH_WEB_LABEL="com.user.dsh-web"
DSH_WEB_PLIST="$HOME/Library/LaunchAgents/com.user.dsh-web.plist"

function dp-start() {
    # 若旧式 PID 文件残留（迁移前），清理掉
    [[ -f "$HOME/.dsh-web.pid" ]] && rm -f "$HOME/.dsh-web.pid"
    if launchctl print "gui/$(id -u)/$DSH_WEB_LABEL" >/dev/null 2>&1; then
        echo "⚠️  launchd 已托管 dsh web，执行重启 (kickstart -k)..."
        launchctl kickstart -k "gui/$(id -u)/$DSH_WEB_LABEL"
    else
        echo "🚀 launchd 加载并启动 dsh web..."
        launchctl bootstrap "gui/$(id -u)" "$DSH_WEB_PLIST" 2>/dev/null \
            || launchctl enable "gui/$(id -u)/$DSH_WEB_LABEL"
        launchctl kickstart "gui/$(id -u)/$DSH_WEB_LABEL"
    fi
    sleep 2
    dp-status
}

function dp-stop() {
    if launchctl print "gui/$(id -u)/$DSH_WEB_LABEL" >/dev/null 2>&1; then
        echo "🛑 卸载 launchd 托管 (bootout) dsh web..."
        launchctl bootout "gui/$(id -u)/$DSH_WEB_LABEL" 2>/dev/null \
            || launchctl disable "gui/$(id -u)/$DSH_WEB_LABEL"
        # 保险：补杀残留的 dsh/node 监听 3080 进程
        local leftovers=$(lsof -tiTCP:3080 -sTCP:LISTEN 2>/dev/null)
        if [[ -n "$leftovers" ]]; then
            echo "  补杀残留进程: $leftovers"
            kill -9 $leftovers 2>/dev/null
        fi
        echo "✅ 已停止"
    else
        echo "⚠️  launchd 未托管 dsh web（可能未启动）"
    fi
}

function dp-status() {
    if launchctl print "gui/$(id -u)/$DSH_WEB_LABEL" >/dev/null 2>&1; then
        local pid=$(launchctl print "gui/$(id -u)/$DSH_WEB_LABEL" 2>/dev/null | awk '/pid =/{print $3; exit}')
        echo "✅ dsh web 由 launchd 托管中 (PID: ${pid:-?})，日志: /tmp/dsh-web.log"
    else
        echo "❌ dsh web 未托管运行 —— 执行 dp-start"
    fi
}

##########################################################
# dsh 远程转发：easytier 虚拟 IP:3080 → 本机 127.0.0.1:3080（手机远程操控 DSH）——2026-08-30
function fwd-start() {
    if [[ -f /tmp/dsh-fwd.pid ]] && kill -0 $(cat /tmp/dsh-fwd.pid) 2>/dev/null; then
        echo "转发器已在运行 (PID: $(cat /tmp/dsh-fwd.pid))"; return 1
    fi
    nohup python3 ~/.local/bin/dsh-remote-fwd.py 10.10.10.22 3080 3080 > /tmp/dsh-fwd.log 2>&1 &
    echo $! > /tmp/dsh-fwd.pid
    echo "✅ dsh 远程转发已启动 (10.10.10.22:3080 -> 127.0.0.1:3080, PID: $!)"
}
function fwd-stop() {
    if [[ -f /tmp/dsh-fwd.pid ]]; then
        kill $(cat /tmp/dsh-fwd.pid) 2>/dev/null; rm -f /tmp/dsh-fwd.pid; echo "已停止"
    else echo "无 PID 文件"; fi
}

##########################################################
# dsh 插件安全更新（本地隔离测试版）——2026-09-04
# dp-update          交互式检查+隔离测试+更新
# dp-update --auto   全自动（供 launchd 每日调用）
# dp-update --check  只检测新版本
function dp-update() {
    bash ~/.local/bin/dsh-plugin-updater.sh "${1:-}"
}

##########################################################
# Mac 系统定期维护（mole CLI）——2026-09-05
# mole-maintain           完整一轮（健康+清理+优化，无 sudo 部分）
# mole-maintain --check   只记录健康状态
# mole-maintain --sudo    sudo 完全体（先 sudo -v 输密码再跑；密码绝不保存）
# launchd com.user.mole-maintain 每周日 04:00 自动跑（sudo 部分会话中提醒）
function mole-maintain() {
    ~/.local/bin/mole-maintain "${1:-full}"
}


# dsh web token 访问（0.1.2+ 每次启动生成新 token；首次带 token 访问种 30 天 cookie）
# 用法：dp-token        # 取当前 token 并在浏览器打开（之后 30 天直接访问即可）
function dp-token() {
    local url
    url=$(grep -oE 'http://127.0.0.1:3080/\?token=[A-Za-z0-9_-]+' /tmp/dsh-web.log 2>/dev/null | tail -1)
    if [[ -z "$url" ]]; then
        echo "❌ 未找到 token URL（dsh web 是否在运行？日志: /tmp/dsh-web.log）"
        return 1
    fi
    open "$url"
    echo "✅ 已用 token 打开（种 30 天 cookie）: ${url:0:50}..."
}
