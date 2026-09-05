#!/bin/bash
# ============================================================
# dsh 升级 0.1.1-rc.2 → 0.1.2-rc.1（含共享层 + 补丁重打 + 重启）
# 2026-09-05 由用户确认执行；运行需约 5-10 分钟
# 用法：在终端运行  bash ~/.files/dsh/bin/dsh-upgrade.sh
# 注意：末尾会重启 dsh web（当前会话短暂断开，刷新即回）
# ============================================================
set -uo pipefail
LOG="/tmp/dsh-upgrade.log"
NPM_CACHE="$HOME/.npm-upgrade-cache"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

echo "=== dsh 升级脚本开始 ===" | tee -a "$LOG"

# 1. 记录当前版本
log "[1/7] 当前 dsh: $(dsh --version 2>&1 | head -1)"
dsh --version > /tmp/dsh-version-before.txt 2>&1

# 2. 备份补丁（升级后需重打）
PATCH="/opt/homebrew/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js"
cp "$PATCH" /tmp/client.js.patched-before-upgrade.bak 2>/dev/null && log "[2/7] 补丁已备份"
grep -n 'createApiClient' "$PATCH" | head -2 >> "$LOG"

# 3. 升级 dsh（用独立 npm cache 避免 ~/.npm 权限问题）
log "[3/7] npm install -g @deepseek-ai/dsh@0.1.2-rc.1（独立 cache，可能数分钟）..."
mkdir -p "$NPM_CACHE"
npm install -g @deepseek-ai/dsh@0.1.2-rc.1 --cache "$NPM_CACHE" 2>&1 | tail -5 >> "$LOG"
log "  升级完成，新版本: $(dsh --version 2>&1 | head -1)"

# 4. 同步升级共享层（profiles/node_modules 下的 @deepseek-ai 包到 0.1.2-rc.1）
log "[4/7] 同步共享层 bundle 包..."
cd ~/.dsh/profiles
# 用 pnpm 更新共享层（在 web profile 里执行，nodeLinker hoisted 会写 profiles/node_modules）
cd ~/.dsh/profiles/web
pnpm update @deepseek-ai/dsh-base @deepseek-ai/dsh-web-app @deepseek-ai/dsh-web-frontend @deepseek-ai/dsh-session @deepseek-ai/dsh-session-query @deepseek-ai/dsh-session-persistence-jsonl --latest 2>&1 | tail -5 >> "$LOG"
log "  共享层更新完成"

# 5. 重打 remote-web-ui 补丁（若新版仍需）
log "[5/7] 检查并重打 createApiClient 补丁..."
NPATCH="/opt/homebrew/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js"
if grep -q 'createApiClient?.()' "$NPATCH" 2>/dev/null; then
    log "  补丁已自带（新版修复），无需重打"
else
    sed -i '' 's/transport?.createApiClient()/transport?.createApiClient?.()/' "$NPATCH" 2>/dev/null
    grep -q 'createApiClient?.()' "$NPATCH" && log "  补丁已重打" || log "  ⚠️ 补丁路径变化，需手动检查"
fi

# 6. 验证新版本核心包
log "[6/7] 验证版本..."
for p in dsh-base dsh-web-app dsh-session-query; do
    v=$(python3 -c "import json; print(json.load(open('$HOME/.dsh/profiles/node_modules/@deepseek-ai/$p/package.json'))['version'])" 2>/dev/null)
    log "  $p → $v"
done

# 7. 重启 dsh web + 健康检查
log "[7/7] 重启 dsh web（launchd）..."
launchctl kickstart -k "gui/$(id -u)/com.user.dsh-web"
sleep 10
code=$(curl -s -m 5 -o /dev/null -w "%{http_code}" http://127.0.0.1:3080 2>/dev/null)
if [[ "$code" =~ ^(200|302)$ ]]; then
    log "✅ dsh web 健康 (HTTP $code) —— 升级完成！"
else
    log "❌ dsh web 未健康 (HTTP $code) —— 回滚中..."
    npm install -g @deepseek-ai/dsh@0.1.1-rc.2 --cache "$NPM_CACHE" 2>&1 | tail -3 >> "$LOG"
    launchctl kickstart -k "gui/$(id -u)/com.user.dsh-web"
fi
log "=== 升级脚本结束 ==="
