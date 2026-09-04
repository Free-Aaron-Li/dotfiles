#!/bin/bash
# dsh web 迁移到 launchd 托管 —— 一步切换脚本
# 2026-09-04：ghostty 退出即 harness 失联的根因修复
# 用法：在新终端执行  bash ~/.local/bin/dsh-web-migrate.sh
# 预期：本 Web 会话短暂断线（杀掉旧进程的瞬间），launchd 新实例数秒内接管，
#       刷新 http://127.0.0.1:3080 即回（会话历史在磁盘，不丢）。
set -u
LABEL="com.user.dsh-web"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
UID_N=$(id -u)

echo "==> [1/4] source 新 dp 函数（加载 .zshrc）"
source "$HOME/.zshrc" 2>/dev/null || true

echo "==> [2/4] 停止旧进程（bootout + 补杀 3080 残留）"
launchctl bootout "gui/$UID_N/$LABEL" 2>/dev/null && echo "    旧 launchd 托管已卸载" || echo "    无旧 launchd 托管（正常）"
LEFTOVERS=$(lsof -tiTCP:3080 -sTCP:LISTEN 2>/dev/null | tr '\n' ' ')
if [[ -n "$LEFTOVERS" ]]; then
    echo "    补杀旧 dsh 进程: $LEFTOVERS"
    kill -9 $LEFTOVERS 2>/dev/null
    sleep 2
else
    echo "    3080 已空闲"
fi
rm -f "$HOME/.dsh-web.pid"

echo "==> [3/4] launchd 加载并启动"
launchctl bootstrap "gui/$UID_N" "$PLIST" 2>/dev/null && echo "    bootstrap OK"
launchctl enable "gui/$UID_N/$LABEL" 2>/dev/null
launchctl kickstart "gui/$UID_N/$LABEL" 2>/dev/null

echo "==> [4/4] 健康检查（最多等 30s）"
for i in $(seq 1 15); do
    sleep 2
    if curl -s -m 2 -o /dev/null -w "%{http_code}" http://127.0.0.1:3080 2>/dev/null | grep -qE '200|302'; then
        echo "    ✅ dsh web 已就绪（launchd PID: $(launchctl print gui/$UID_N/$LABEL 2>/dev/null | awk '/pid =/{print $3; exit}')）"
        echo "    🎉 现在关掉 ghostty 也不会影响 harness 了"
        exit 0
    fi
    echo "    等待中... ($i/15)"
done
echo "    ❌ 30s 内未就绪，请手动检查: dp-status / tail /tmp/dsh-web.log"
exit 1
