#!/bin/bash
# dsh web 包装脚本 —— 供 launchd 托管（com.user.dsh-web）
# 目的：让 dsh web 完全后台运行，脱离任何终端（ghostty 退出不影响），崩溃由 launchd KeepAlive 自启。
# 2026-09-04 建立 launchd 托管；2026-09-05 加「启动前自动 npm 升级」：
#   launchd 每次拉起（开机/崩溃重启/kickstart）时，先查 registry 最新版，
#   有新版则 npm install -g 升级（保持 npm 单实例，不引入 npx 多实例坑），再启动 web。
# 注意：升级会还原 dsh-client-connection 补丁（createApiClient?.()），需重打。

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOME="/Users/lijc"
LOG="/tmp/dsh-web.log"

log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# ---- 启动前自动升级（失败不阻断启动）----
auto_upgrade() {
    local CURRENT LATEST
    CURRENT=$(python3 -c "import json; print(json.load(open('/opt/homebrew/lib/node_modules/@deepseek-ai/dsh/package.json'))['version'])" 2>/dev/null)
    LATEST=$(curl -s -m 8 "https://registry.npmjs.org/@deepseek-ai/dsh/latest" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('version',''))" 2>/dev/null)
    if [[ -z "$LATEST" || "$LATEST" == "$CURRENT" ]]; then
        log "版本检查: 当前 $CURRENT 已最新（latest=$LATEST）"
        return 0
    fi
    log "发现新版: $CURRENT -> $LATEST，自动升级..."
    mkdir -p "$HOME/.npm-upgrade-cache"
    if npm install -g "@deepseek-ai/dsh@$LATEST" --cache "$HOME/.npm-upgrade-cache" >> "$LOG" 2>&1; then
        log "升级成功 -> $LATEST"
        local PATCH="/opt/homebrew/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js"
        if [[ -f "$PATCH" ]] && ! grep -q 'createApiClient?.()' "$PATCH" 2>/dev/null; then
            sed -i '' 's/transport?.createApiClient()/transport?.createApiClient?.()/' "$PATCH" 2>/dev/null
            grep -q 'createApiClient?.()' "$PATCH" && log "remote-web-ui 补丁已重打" || log "WARN 补丁重打失败，需人工处理"
        fi
    else
        log "WARN 自动升级失败，继续用当前版本启动"
    fi
}

log "=== dsh web 启动 ==="
auto_upgrade
exec /opt/homebrew/bin/dsh web --no-open >> "$LOG" 2>&1
