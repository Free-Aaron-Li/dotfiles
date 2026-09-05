#!/bin/bash
# ============================================================
# mole 定期维护：清理 + 优化 + 健康报告 —— 2026-09-05
# 用户全局任务：确保 Mac 高效流畅运行（mole CLI 1.53.0）
# 调度:   launchd com.user.mole-maintain 每周日 04:00（自动，无 sudo 部分）
# 手动:   mole-maintain            # 完整一轮（无 sudo 部分）
#         mole-maintain --check    # 只记录健康状态
#         mole-maintain --sudo     # sudo 完整版（需先 sudo -v 授权；清系统级缓存+全量优化）
# 行为:   非交互自动模式——用户级清理/优化自动执行；
#         需 sudo 的系统级项自动跳过 → 写 sudo-pending 标记（会话中提醒用户授权后跑 --sudo）
# 报告:   ~/.dsh/mole-report.md（可并入每日首会话汇报）
# 标记:   ~/.dsh/mole-sudo-pending（存在 = 有待 sudo 项，会话中提醒）
# 🔒 安全: 密码绝不保存/记录——sudo 授权只在用户终端输入（sudo -v 缓存 5 分钟）
# ============================================================
set -uo pipefail
LOG="/tmp/mole-maintain.log"
REPORT="$HOME/.dsh/mole-report.md"
PENDING="$HOME/.dsh/mole-sudo-pending"
MODE="${1:-full}"

log() { echo "[$(date '+%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

report_init() {
    local today
    today=$(date '+%Y-%m-%d')
    if [[ ! -f "$REPORT" ]] || ! grep -q "^# mole 维护报告：$today" "$REPORT" 2>/dev/null; then
        {
            echo "# mole 维护报告：$today"
            echo ""
            echo "> 由 com.user.mole-maintain 每周日 04:00 自动运行（mole 1.53.0，macOS 26.6.2）"
            echo ""
        } > "$REPORT"
    fi
}
rep() { echo "$*" >> "$REPORT"; }

# --- 健康状态 ---
health() {
    log "📊 采集健康状态..."
    local st
    st=$(mole status 2>/dev/null)
    local score msg cpu mem disk purge
    score=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('health_score','?'))" 2>/dev/null)
    msg=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('health_score_msg','?'))" 2>/dev/null)
    cpu=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);print(round(d.get('cpu',{}).get('usage',0),1))" 2>/dev/null)
    mem=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);print(round(d.get('memory',{}).get('used_percent',0),1))" 2>/dev/null)
    disk=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);ds=d.get('disks',[{}])[0];print(round(ds.get('used_percent',0),1))" 2>/dev/null)
    purge=$(echo "$st" | python3 -c "import sys,json;d=json.load(sys.stdin);ds=d.get('disks',[{}])[0];print(round(ds.get('purgeable',0)/1e9,1))" 2>/dev/null)
    rep ""
    rep "## 健康状态（$(date '+%H:%M')）"
    rep ""
    rep "- **健康分：$score / 100（$msg）**"
    rep "- CPU: ${cpu}% | 内存: ${mem}% | 磁盘: ${disk}%（可清理 ${purge}GB）"
    rep ""
    # 瓶颈提示（top process）
    local top
    top=$(echo "$st" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for p in d.get('top_processes',[])[:3]:
    print(f\"- {p.get('name','?')} {p.get('cpu_percent',0)}% CPU\")
" 2>/dev/null)
    if [[ -n "$top" ]]; then rep "### 高占用进程"; rep "$top"; rep ""; fi
    log "  健康分: $score/100 ($msg)"
}

# --- 清理（记录需 sudo 项）---
cleanup() {
    log "🧹 执行 mole clean..."
    local out
    out=$(mole clean 2>&1)
    # 提取摘要
    echo "$out" | grep -E "Cleanup complete|Items cleaned|Free space|Tracked" | sed 's/^/  /' | tee -a "$LOG"
    local summary
    summary=$(echo "$out" | grep -E "Cleanup complete|Items cleaned|Free space" | tr '\n' ' ')
    rep "## 清理结果"
    rep ""
    rep "- $summary"
    # 检测 sudo 跳过项 —— 用 python 清洗行首符号
    local sudo_items
    sudo_items=$(echo "$out" | python3 -c "
import sys, re
for line in sys.stdin:
    low = line.lower()
    if 'requires sudo' in low or 'requires admin' in low or 'sudo denied' in low or 'system-level cleanup skipped' in low:
        # 剥离行首所有非字母数字符号 + 去重
        clean = re.sub(r'^[^A-Za-z0-9]+', '', line).strip()
        if clean:
            print(clean)
" 2>/dev/null | sort -u)
    if [[ -n "$sudo_items" ]]; then
        rep ""
        rep "### ⚠️ 需 sudo 手动执行的系统级清理（对话时提醒用户）"
        rep ""
        while IFS= read -r line; do
            [[ -n "$line" ]] && rep "- $line"
        done <<< "$sudo_items"
        rep ""
        rep "> 手动执行：\`mole-maintain --sudo\`（会提示输入密码；密码只在你终端输入，绝不保存）"
        # 写 pending 标记（会话中 agent 检测到即提醒用户）
        echo "pending: $(date '+%Y-%m-%d %H:%M')" > "$PENDING"
    else
        rm -f "$PENDING"
    fi
    rep ""
}

# --- ANSI 颜色码清洗 ---
strip_ansi() { sed -e $'s/\x1b\[[0-9;]*m//g'; }

# --- sudo 完整版（用户已 sudo -v 授权后调用）---
sudo_full() {
    log "🔐 sudo 完整版：先验证 sudo 授权（未授权则提示，绝不保存密码）..."
    # 验证 sudo 是否已缓存授权（-n 非交互；失败=未授权）
    if ! sudo -n true 2>/dev/null; then
        echo "❌ sudo 未授权。请在终端执行: sudo -v （输入密码，缓存 5 分钟）然后重跑 mole-maintain --sudo"
        log "sudo 未授权，中止"
        exit 1
    fi
    log "  sudo 已授权，执行系统级清理..."
    # 清理前状态（磁盘/健康）
    local disk_before free_before
    disk_before=$(df -k / | awk 'NR==2{printf "%.1f", ($3+$4)/1024/1024}')
    free_before=$(df -k / | awk 'NR==2{printf "%.1f", $4/1024/1024}')
    local score_before
    score_before=$(mole status 2>/dev/null | python3 -c "import sys,json;print(json.load(sys.stdin).get('health_score','?'))" 2>/dev/null)

    rep ""
    rep "## 🔐 sudo 完全体运行（$(date '+%H:%M')）"
    rep ""
    rep "- 清理前：磁盘使用 ${disk_before}GB / 空闲 ${free_before}GB | 健康分 ${score_before}"

    # 系统级 clean
    log "  [1/3] mole clean（系统级）..."
    local out
    out=$(mole clean 2>&1)
    local clean_summary clean_freed
    clean_summary=$(echo "$out" | strip_ansi | grep -E "Cleanup complete|Items cleaned" | tr '\n' ' ')
    clean_freed=$(echo "$out" | strip_ansi | grep -oE '\([-+]?[0-9.]+[KMG]?B\)' | tail -1)
    echo "$clean_summary" | sed 's/^/    /' >> "$LOG"
    rep "- 系统级清理：${clean_summary:-完成}"

    # optimize 全量
    log "  [2/3] mole optimize（全量）..."
    out=$(mole optimize 2>&1)
    local diag bottleneck_line
    diag=$(echo "$out" | strip_ansi | grep -E "✓" | head -10 | sed 's/^[[:space:]]*//' | tr '\n' '; ')
    bottleneck_line=$(echo "$out" | strip_ansi | grep -iE "bottleneck" | head -1)
    rep "- 全量优化：${bottleneck_line:-无持续瓶颈}"
    rep "  - 已执行：${diag:-见日志}"

    # 清理后统计
    log "  [3/3] 统计结果..."
    local disk_after free_after score_after
    disk_after=$(df -k / | awk 'NR==2{printf "%.1f", ($3+$4)/1024/1024}')
    free_after=$(df -k / | awk 'NR==2{printf "%.1f", $4/1024/1024}')
    score_after=$(mole status 2>/dev/null | python3 -c "import sys,json;print(json.load(sys.stdin).get('health_score','?'))" 2>/dev/null)
    local freed_gb
    freed_gb=$(python3 -c "print(f'{$free_after-$free_before:+.2f}')")
    rep ""
    rep "### 📊 结果统计"
    rep ""
    rep "| 指标 | 清理前 | 清理后 | 变化 |"
    rep "|---|---|---|---|"
    rep "| 磁盘空闲 | ${free_before}GB | ${free_after}GB | **${freed_gb}GB** |"
    rep "| 健康分 | ${score_before} | ${score_after} | — |"
    rep ""
    rep "✅ **sudo 完全体完成**：系统级缓存已清 + 全量优化已跑"
    rep ""
    rm -f "$PENDING"
    log "sudo 完全体运行完成，pending 标记已清除"
}

# --- 优化 ---
optimize() {
    log "⚡ 执行 mole optimize..."
    local out
    out=$(mole optimize 2>&1)
    echo "$out" | grep -E "✓|Skipping|bottleneck" | head -20 | sed 's/^/  /' | tee -a "$LOG"
    local bottleneck
    bottleneck=$(echo "$out" | grep -iE "bottleneck" | head -2 | tr '\n' ' ')
    rep "## 优化结果"
    rep ""
    [[ -n "$bottleneck" ]] && rep "- 诊断: $bottleneck"
    local skipped
    skipped=$(echo "$out" | grep -icE "skipped \(admin|requires admin")
    rep "- 完成 Finder/DNS检查/LaunchServices 等优化；${skipped} 项需 sudo 跳过"
    rep ""
    # 高占用提示
    if echo "$out" | grep -q "bottleneck: WindowServer"; then
        rep "> 💡 WindowServer 持续高占用 = 桌面合成忙/长期未重启。可考虑重启 Mac 或关多余窗口。"
        rep ""
    fi
}

# --- 主流程 ---
report_init
if [[ "$MODE" == "--sudo" ]]; then
    sudo_full
    log "=== sudo 完全体完成 ==="
    exit 0
fi
if [[ "$MODE" == "--check" ]]; then
    health
    log "=== 状态检查完成 ==="
    exit 0
fi
health
cleanup
optimize
log "=== mole 维护完成 ==="
