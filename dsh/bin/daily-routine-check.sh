#!/bin/bash
# ============================================================
# 每日例行检查：总结缺失检测 + 报告状态 —— 2026-09-05
# 用户全局约定：每天 11:30 总结昨日/当日 → 全局记忆 → 滴答梳理
#              每天首个会话汇报（插件更新 + mole + 总结状态）
# 机制：launchd 11:30 运行本脚本 → 生成 ~/.dsh/daily-routine.md
#      （含：昨日总结缺失? 今日已总结? 插件/mole 报告状态）
#      每次会话开始 agent 读 daily-routine.md + 各 pending 标记 → 汇报
# ============================================================
set -uo pipefail
MEM_DIR="$HOME/source/qt/ecas/.memsearch/memory"
ROUTINE="$HOME/.dsh/daily-routine.md"
TODAY=$(date '+%Y-%m-%d')
YESTERDAY=$(date -v-1d '+%Y-%m-%d' 2>/dev/null || date -d yesterday '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')
NOW=$(date '+%H:%M')

{
    echo "# 每日例行状态：$TODAY $NOW"
    echo ""
    echo "## 📝 总结状态"
} > "$ROUTINE"

# 昨日总结检查
YFILE="$MEM_DIR/$YESTERDAY.md"
if [[ -f "$YFILE" ]] && grep -q "工作总结" "$YFILE" 2>/dev/null; then
    echo "- ✅ 昨日($YESTERDAY)总结：已归档" >> "$ROUTINE"
else
    echo "- ⚠️ 昨日($YESTERDAY)总结：**缺失** → 需补录" >> "$ROUTINE"
fi

# 今日是否已有总结（晚间重复运行防重复）
TFILE="$MEM_DIR/$TODAY.md"
if [[ -f "$TFILE" ]] && grep -q "工作总结" "$TFILE" 2>/dev/null; then
    echo "- ✅ 今日($TODAY)总结：已有（晚间收尾时更新即可）" >> "$ROUTINE"
else
    echo "- ⏳ 今日($TODAY)总结：未做（晚间 21:00 例行提醒）" >> "$ROUTINE"
fi

echo "" >> "$ROUTINE"
echo "## 🔄 维护状态" >> "$ROUTINE"

# 插件更新状态：报告最新段若全是 ✅/⏭️（已处理）则视为无待更新
if [[ -f "$HOME/.dsh/plugin-update-report.md" ]]; then
    LAST=$(python3 - "$HOME/.dsh/plugin-update-report.md" <<'PYX'
import sys
text = open(sys.argv[1], encoding='utf-8').read()
secs = text.split('# dsh 插件更新报告')
last = secs[-1] if len(secs) > 1 else text
print(last[-1200:])
PYX
)
    if echo "$LAST" | grep -q "全部插件已是最新"; then
        echo "- ✅ 插件：全部最新（03:00 定时检查）" >> "$ROUTINE"
    elif echo "$LAST" | grep -qE "^[- ] ✅|⏭️"; then
        echo "- ✅ 插件：最新更新已应用（见报告尾段）" >> "$ROUTINE"
    elif echo "$LAST" | grep -qE "→"; then
        echo "- 🔔 插件：有未处理更新项 → 提醒用户 dp-update --auto（手动）" >> "$ROUTINE"
    else
        echo "- 📄 插件：报告存在（见 plugin-update-report.md）" >> "$ROUTINE"
    fi
else
    echo "- ⚠️ 插件：无报告文件（定时任务未跑？）" >> "$ROUTINE"
fi

# mole sudo 待办
if [[ -f "$HOME/.dsh/mole-sudo-pending" ]]; then
    echo "- 🔐 mole：有 sudo 待办 → 提醒用户 \`sudo -v && mole-maintain --sudo\`" >> "$ROUTINE"
else
    echo "- ✅ mole：无 sudo 待办" >> "$ROUTINE"
fi

# 🔄 重启提醒（2026-09-06 加：uptime >10 天或 WindowServer 高占用时提醒）
RESTART_HINT=""
UPTIME_DAYS=$(uptime 2>/dev/null | sed -E 's/.*up ([0-9]+) days.*/\1/' | grep -E '^[0-9]+$' || echo 0)
# WindowServer CPU 采样（ps 可用时）
WS_CPU=$(ps -eo pcpu,comm 2>/dev/null | awk '/WindowServer/ {print int($1); exit}')
if [[ "$UPTIME_DAYS" -ge 10 ]] || { [[ -n "$WS_CPU" ]] && [[ "$WS_CPU" -ge 30 ]]; }; then
    RESTART_HINT="⚠️ 建议重启：已运行 ${UPTIME_DAYS} 天"
    [[ -n "$WS_CPU" && "$WS_CPU" -ge 30 ]] && RESTART_HINT="${RESTART_HINT}，WindowServer ${WS_CPU}% CPU（桌面合成负担）"
    echo "- ${RESTART_HINT} → 找合适时机重启 Mac（launchd 服务会自动恢复）" >> "$ROUTINE"
else
    echo "- ✅ 系统运行健康：uptime ${UPTIME_DAYS} 天，WindowServer ${WS_CPU:-?}% CPU" >> "$ROUTINE"
fi

# 🔐 密钥轮换到期检查（2026-09-10 加：60 天周期，状态见 security-rotation.json）
ROT_STATE="$HOME/env/dsh/security-rotation.json"
if [[ -f "$ROT_STATE" ]]; then
    python3 - "$ROT_STATE" <<'PYEOF' >> "$ROUTINE"
import json, sys
from datetime import date
try:
    d = json.load(open(sys.argv[1]))
    nxt = date.fromisoformat(d["next_due"])
    left = (nxt - date.today()).days
    n = len(d.get("items", []))
    if left < 0:
        print(f"- 🚨 **密钥轮换已逾期 {abs(left)} 天**（应于 {nxt} 执行，共 {n} 项）→ 立即 `rotate-credential.py list`")
    elif left <= 14:
        print(f"- ⚠️ 密钥轮换临近：还剩 {left} 天（{nxt} 到期，共 {n} 项）→ 提前安排")
    else:
        print(f"- ✅ 密钥轮换：{nxt} 到期（还剩 {left} 天，共 {n} 项）")
except Exception as e:
    print(f"- ⚠️ 密钥轮换状态读取失败：{e}")
PYEOF
fi

echo "" >> "$ROUTINE"
echo "## 🤖 Hindsight 本地 AI 监测" >> "$ROUTINE"

# 1. daemon 健康
if curl -s -m 4 http://127.0.0.1:9077/health 2>/dev/null | grep -q healthy; then
    echo "- ✅ daemon：健康" >> "$ROUTINE"
else
    echo "- ❌ daemon：**不健康/未运行** → 需立即处理（launchctl kickstart com.user.hindsight.daemon）" >> "$ROUTINE"
fi

# 2. 最近 retain 路由检查（retain 必须走本地 ollama，禁 deepseek）
RET=$(curl -s -m 8 "http://127.0.0.1:9077/v1/default/banks/coding-agent::ecas/llm-requests?limit=200" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    retains = [it for it in d.get('items', []) if it.get('operation') == 'retain']
    if not retains:
        print('NO_RETAIN')
        sys.exit()
    # 取最新一条 success retain 的路由
    latest_ok = next((it for it in retains if it.get('status') == 'success'), None)
    if not latest_ok:
        print('NO_SUCCESS')
        sys.exit()
    print(latest_ok.get('provider') + '/' + latest_ok.get('model'))
except Exception:
    print('ERR')
" 2>/dev/null)
if [[ "$RET" == "NO_RETAIN" || "$RET" == "NO_SUCCESS" ]]; then
    echo "- ⏳ retain：近期无成功记录（任务量少属正常；有失败会单独提示）" >> "$ROUTINE"
elif [[ "$RET" == "ERR" || -z "$RET" ]]; then
    echo "- ⚠️ retain：路由查询失败" >> "$ROUTINE"
elif echo "$RET" | grep -q "ollama"; then
    echo "- ✅ retain 走本地：$RET" >> "$ROUTINE"
else
    echo "- ❌ retain 走 $RET → **本地 AI 失效，烧 token！** 需排查（uv tool list / ollama / daemon 日志）" >> "$ROUTINE"
fi

# 3. 全面路由 + token 消耗检查（2026-09-05 加：防 mental model/reflect 烧钱）
ROUTE=$(curl -s -m 8 "http://127.0.0.1:9077/v1/default/banks/coding-agent::ecas/llm-requests?limit=200" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    import datetime
    items = d.get('items', [])
    # 只看最近 30 分钟内调用（避免修复前历史记录误报）
    cutoff = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(minutes=10)).isoformat()
    items = [it for it in items if it.get('started_at','') > cutoff][:50]
    from collections import defaultdict
    hot = defaultdict(lambda: {'n':0,'tin':0})
    for it in items:
        op = it.get('operation','?')
        prov = it.get('provider')
        if op in ('retain','refresh_mental_model','mental_model_delta_ops') and prov == 'deepseek' and it.get('status') == 'success':
            hot[op]['n'] += 1
            hot[op]['tin'] += it.get('input_tokens') or 0
    if not hot:
        print('CLEAN')
    else:
        for op, a in hot.items():
            print(f'{op}:{a[\"n\"]}次/{a[\"tin\"]}tok')
except Exception:
    print('ERR')
" 2>/dev/null)
if [[ "$ROUTE" == "CLEAN" ]]; then
    echo "- ✅ 路由健康：retain/mental/reflect 近 200 条无 deepseek" >> "$ROUTINE"
elif [[ "$ROUTE" == "ERR" ]]; then
    echo "- ⚠️ 路由全面检查失败" >> "$ROUTINE"
else
    echo "- ❌ 检测到 deepseek 混用：$ROUTE → **烧 token！** 查 mental model 节流/reflect 配置" >> "$ROUTINE"
fi

# 4. 今日 deepseek token 消耗趋势（对比昨日）
DS_TODAY=$(curl -s -m 8 "http://127.0.0.1:9077/v1/default/banks/coding-agent::ecas/llm-requests/stats" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    buckets = d.get('buckets', [])
    if buckets:
        last = buckets[-1]
        print(f\"{last.get('time','')[:10]} in={last.get('tokens',{}).get('input',0):,}\")
except Exception: pass
" 2>/dev/null)
if [[ -n "$DS_TODAY" ]]; then
    echo "- 📊 最近统计：$DS_TODAY（input tokens，deepseek 大头；应随节流下降）" >> "$ROUTINE"
fi

# 5. 二进制存在性（防 uv cache 被清事故重演）
if [[ -x "$HOME/.local/bin/hindsight-api" ]]; then
    echo "- ✅ hindsight-api 二进制：就位（~/.local/bin）" >> "$ROUTINE"
else
    echo "- ❌ hindsight-api 二进制缺失 → 需 uv tool install hindsight-api" >> "$ROUTINE"
fi

# 输出供 agent 读取
cat "$ROUTINE"
