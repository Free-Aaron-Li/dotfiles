#!/usr/bin/env bash
# Hindsight daemon 启动包装（供 launchd 调用）
# 关键：source coding-agent.env（含 ollama 主 LLM + deepseek 覆盖配置）
DAEMON="/Users/lijc/.local/bin/hindsight-api"
ENVF="/Users/lijc/.hindsight/profiles/coding-agent.env"
LOGF="/Users/lijc/.hindsight/profiles/coding-agent.log"

cd /Users/lijc
set -a
source "$ENVF"
set +a
exec "$DAEMON" --idle-timeout 0 --port 9077
