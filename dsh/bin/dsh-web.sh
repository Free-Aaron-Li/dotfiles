#!/bin/bash
# dsh web 包装脚本 —— 供 launchd 托管（com.user.dsh-web）
# 目的：让 dsh web 完全后台运行，脱离任何终端（ghostty 退出不影响），崩溃由 launchd KeepAlive 自启。
# 2026-09-04 建立，替换原 .zshrc dp-start 的 nohup & 方式（nohup 防不住 dsh 派生 node 子进程的 SIGHUP）

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOME="/Users/lijc"

# 日志
LOG="/tmp/dsh-web.log"
exec /opt/homebrew/bin/dsh web --no-open >> "$LOG" 2>&1
