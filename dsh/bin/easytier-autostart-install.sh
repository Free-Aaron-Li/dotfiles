#!/bin/bash
# ============================================================
# easytier 开机自启安装（LaunchDaemon root 模式）—— 2026-09-06
# 背景：easytier 需 root 建 TUN 虚拟网卡；现手动 sudo nohup 启动，重启后需手动。
# 方案：/Library/LaunchDaemons/com.easytier.daemon.plist（root，开机自启 + KeepAlive）
# 用法：sudo bash ~/.files/dsh/bin/easytier-autostart-install.sh
# 注意：会停掉当前手动实例再启 LaunchDaemon 实例（避免双实例）
# ============================================================
set -euo pipefail
PLIST_SRC="/Users/lijc/.files/dsh/plists/com.easytier.daemon.plist"
PLIST_DST="/Library/LaunchDaemons/com.easytier.daemon.plist"
BIN="/Users/lijc/Applications/easytier/easytier-core"
CONF="/Users/lijc/backup/easytier/mac-config.toml"

echo "=== [1/4] 校验文件 ==="
[[ -f "$PLIST_SRC" ]] || { echo "❌ plist 模板缺失"; exit 1; }
[[ -x "$BIN" ]] || { echo "❌ easytier-core 不存在"; exit 1; }
echo "  OK"

echo "=== [2/4] 停掉当前手动实例（防双实例）==="
pkill -f "easytier-core.*mac-config" 2>/dev/null && echo "  已停手动实例" || echo "  无手动实例（或已停）"
sleep 2
# 也清理 launchd 旧配置（若存在）
launchctl bootout system/com.easytier.daemon 2>/dev/null || true

echo "=== [3/4] 安装 LaunchDaemon ==="
cp "$PLIST_SRC" "$PLIST_DST"
chown root:wheel "$PLIST_DST"
chmod 644 "$PLIST_DST"
plutil -lint "$PLIST_DST"
launchctl bootstrap system "$PLIST_DST"
launchctl enable system/com.easytier.daemon
echo "  已加载"

echo "=== [4/4] 验证 ==="
sleep 5
if launchctl print system/com.easytier.daemon 2>/dev/null | grep -q "state = running"; then
    echo "✅ easytier LaunchDaemon 运行中"
    # 验证虚拟 IP
    ifconfig 2>/dev/null | grep -q "10.10.10.22" && echo "✅ 虚拟 IP 10.10.10.22 已就位" || echo "⚠️ 虚拟 IP 未出现（稍等或查 /tmp/easytier.log）"
    echo "🎉 开机自启已配置（下次开机自动连网）"
else
    echo "❌ LaunchDaemon 未运行，查日志: cat /tmp/easytier.log"
    cat /tmp/easytier.log 2>/dev/null | tail -10
    exit 1
fi
