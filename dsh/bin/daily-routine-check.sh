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

# 输出供 agent 读取
cat "$ROUTINE"
