#!/bin/bash
# ============================================================
# dsh 插件安全自动更新管线（本地隔离版）——2026-09-04
# 用法:  dp-update            # 检查+隔离测试+更新（交互确认）
#        dp-update --auto     # 全自动（launchd 每日调用）
#        dp-update --check    # 只检测新版本并列出
# 流程:  检测新版 → staging(CoW复制+独立端口) 起 web 自检 → 通过→正式更新→重启 launchd→健康检查
#        失败→回滚快照，正式环境不动
# 报告:  每次运行写 ~/.dsh/plugin-update-report.md（当天首次会话由 agent 读取并汇报）
# ============================================================
set -uo pipefail
LOG="/tmp/dsh-plugin-updater.log"
REPORT="$HOME/.dsh/plugin-update-report.md"
PROFILE="$HOME/.dsh/profiles/web"
STAGING="$HOME/.dsh/profiles/web-staging"
LABEL="com.user.dsh-web"
PORT=3199
MODE="${1:-interactive}"

log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

# 报告初始化：新一天覆盖，同一天追加
report_init() {
    local today
    today=$(date '+%Y-%m-%d')
    if [[ ! -f "$REPORT" ]] || ! grep -q "^# $today" "$REPORT" 2>/dev/null; then
        {
            echo "# dsh 插件更新报告：$today"
            echo ""
            echo "> 由 com.user.dsh-plugin-updater 每日 03:00 自动运行（dp-update 也可手动触发）"
            echo ""
            echo "## 运行时间"
            echo "- $(date '+%H:%M:%S')（launchd 定时 / 手动）"
            echo ""
        } > "$REPORT"
    fi
}
report_append() { echo "$*" >> "$REPORT"; }

# --- 1. 检测新版本 ---
detect() {
    log "🔍 检测插件新版本..."
    > /tmp/dsh-pending.txt
    python3 - "$PROFILE/package.json" <<'PY' >> /tmp/dsh-pending.txt
import json, re, sys, urllib.request
d = json.load(open(sys.argv[1]))['dependencies']
for k, v in sorted(d.items()):
    if not re.match(r'^(@[^/]+/)?(dsh|@deepseek-ai/dsh|dshmarket|dsh-)', k): continue
    ver = v.lstrip('^~>=<v')
    if ver.startswith(('git', 'http')): continue
    try:
        req = urllib.request.Request(f"https://registry.npmjs.org/{k.replace('/', '%2F')}/latest", headers={'User-Agent':'dsh-updater'})
        latest = json.load(urllib.request.urlopen(req, timeout=8))['version']
        if latest != ver:
            print(f"{k}\t{ver}\t{latest}")
    except Exception as e:
        print(f"# ERR {k}: {e}", file=sys.stderr)
PY
    n=$(grep -vc '^#' /tmp/dsh-pending.txt 2>/dev/null || true)
    n=$(echo "$n" | tr -dc '0-9')
    if [[ -z "$n" || "$n" -eq 0 ]]; then log "✅ 全部插件已是最新"; return 1; fi
    log "发现 $n 个可更新："
    awk -F'\t' '{printf "   %s: %s → %s\n", $1, $2, $3}' /tmp/dsh-pending.txt | tee -a "$LOG"
    return 0
}

# --- 2. staging 隔离自检：CoW 复制 + 独立端口起 web ---
staging_test() {  # $1 = pkg@newver
    local cand="$1"
    log "🔬 隔离测试 $cand ..."
    rm -rf "$STAGING"
    cp -cR "$PROFILE" "$STAGING" 2>/dev/null || cp -R "$PROFILE" "$STAGING"
    rm -rf "$STAGING/node_modules/.cache" 2>/dev/null
    if ! (cd "$STAGING" && pnpm add "$cand" --prefer-offline >/dev/null 2>&1); then
        log "   ❌ pnpm add 失败（依赖解析/下载）"; return 1
    fi
    # 起 staging web 到独立端口，5s 内要能响应
    ( cd "$STAGING" && nohup /opt/homebrew/bin/dsh web --port "$PORT" --no-open > /tmp/dsh-staging.log 2>&1 & echo $! > /tmp/dsh-staging.pid )
    local ok=0
    for i in $(seq 1 15); do
        sleep 2
        code=$(curl -s -m 3 -o /dev/null -w "%{http_code}" "http://127.0.0.1:$PORT" 2>/dev/null)
        if [[ "$code" =~ ^(200|302)$ ]]; then ok=1; break; fi
        if ! kill -0 $(cat /tmp/dsh-staging.pid 2>/dev/null) 2>/dev/null; then break; fi
    done
    kill $(cat /tmp/dsh-staging.pid 2>/dev/null) 2>/dev/null
    sleep 1
    # 补杀 staging 子进程
    for p in $(lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null); do kill -9 "$p" 2>/dev/null; done
    if [[ "$ok" -eq 1 ]]; then log "   ✅ 通过（web 正常响应）"; return 0; fi
    log "   ❌ 失败（web 未健康启动）—— 见 /tmp/dsh-staging.log 尾部："
    tail -3 /tmp/dsh-staging.log 2>/dev/null | tee -a "$LOG"
    return 1
}

# --- 3. 应用更新 ---
apply() {  # $1 = pkg@newver
    local cand="$1"
    if ! (cd "$PROFILE" && pnpm add "$cand" >/dev/null 2>&1); then
        log "   ❌ 正式更新失败 $cand"; return 1
    fi
    log "   ✅ 已更新 $cand"
}

rollback() {
    log "🚨 健康检查失败，回滚..."
    launchctl kickstart -k "gui/$(id -u)/$LABEL"
    sleep 8
    code=$(curl -s -m 5 -o /dev/null -w "%{http_code}" http://127.0.0.1:3080 2>/dev/null)
    log "回滚后 HTTP: $code"
    [[ "$code" =~ ^(200|302)$ ]] && log "✅ 已恢复" || log "❌ 仍需人工处理（dp-status / 查看日志）"
}

# --- 主流程 ---
report_init
detect
DETECT_N=$?
if [[ "$DETECT_N" -ne 0 ]]; then
    report_append "## 检查结果"
    report_append "- ✅ 全部插件已是最新，无需更新"
    report_append ""
    exit 0
fi
if [[ "$MODE" == "--check" ]]; then
    report_append "## 检查结果（仅检测，未更新）"
    report_append ""
    exit 0
fi

report_append "## 检测到可更新"
awk -F'\t' '{printf "- %s: %s → %s\n", $1, $2, $3}' /tmp/dsh-pending.txt >> "$REPORT"
report_append ""

# 快照（文件级）
SNAP="$HOME/.dsh/plugin-update-snap/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$SNAP"
cp "$PROFILE/package.json" "$PROFILE/pnpm-lock.yaml" "$SNAP/" 2>/dev/null
log "📸 快照: $SNAP"

report_append "## 更新明细"
while IFS=$'\t' read -r PKG OLD NEW; do
    [[ "$PKG" == \#* || -z "$PKG" ]] && continue
    CAND="$PKG@$NEW"
    if [[ "$MODE" == "--auto" ]]; then
        if staging_test "$CAND"; then
            if apply "$CAND"; then
                report_append "- ✅ $PKG: $OLD → $NEW（隔离测试通过）"
            else
                report_append "- ❌ $PKG: $OLD → $NEW（正式更新失败）"
            fi
        else
            report_append "- ⚠️ $PKG: $OLD → $NEW（隔离测试未过，跳过）"
        fi
    else
        echo -n "  更新 $CAND ? [y/N] "; read -r ans
        if [[ "$ans" =~ ^[yY] ]]; then
            staging_test "$CAND" && apply "$CAND"
            report_append "- ✅ $PKG: $OLD → $NEW（已确认更新）"
        else
            log "   ↪ 跳过"
            report_append "- ⏭️ $PKG: $OLD → $NEW（用户跳过）"
        fi
    fi
done < /tmp/dsh-pending.txt
rm -f /tmp/dsh-pending.txt
report_append ""

# 重启正式实例 + 健康检查
if [[ -n "$(ls "$SNAP" 2>/dev/null)" ]]; then
    log "🔄 重启 dsh web..."
    launchctl kickstart -k "gui/$(id -u)/$LABEL"
    sleep 8
    code=$(curl -s -m 5 -o /dev/null -w "%{http_code}" http://127.0.0.1:3080 2>/dev/null)
    if [[ "$code" =~ ^(200|302)$ ]]; then
        log "✅ dsh web 健康 (HTTP $code)"
        report_append "## 结果：✅ dsh web 健康（HTTP $code）"
    else
        log "❌ dsh web 不健康 (HTTP $code)"
        report_append "## 结果：❌ dsh web 不健康（HTTP $code），已回滚"
        # 回滚 package.json + lockfile
        cp "$SNAP/package.json" "$PROFILE/" 2>/dev/null
        cp "$SNAP/pnpm-lock.yaml" "$PROFILE/" 2>/dev/null
        (cd "$PROFILE" && pnpm install >/dev/null 2>&1)
        rollback
    fi
    report_append ""
fi
log "=== 结束 ==="
