#!/bin/bash

# 用户桌面文件路径
USER_DESKTOP_FILE="$HOME/.local/share/applications/obsidian.desktop"
ICON_DIR="/opt/Obsidian/icons"

# 如果用户目录下没有桌面文件，则从系统复制
mkdir -p "$(dirname "$USER_DESKTOP_FILE")"
[ ! -f "$USER_DESKTOP_FILE" ] && \
cp /usr/share/applications/obsidian.desktop "$USER_DESKTOP_FILE"

# 随机选择图标（0-21）
icon_number=$(( RANDOM % 22 ))
icon_path="$ICON_DIR/${icon_number}.svg"

# 更新桌面文件
sed -i "s|^Icon=.*|Icon=$icon_path|" "$USER_DESKTOP_FILE"

# 更新桌面数据库
update-desktop-database "$HOME/.local/share/applications/"

# Deepin 专用图标刷新命令（可能需要根据实际环境调整）
if hash gtk-update-icon-cache 2>/dev/null; then
  gtk-update-icon-cache -f ~/.local/share/icons/hicolor/
fi

# 尝试通过 DDE Dock 刷新（Deepin V20+ 验证有效）
if [ -x "$(command -v dde-dock)" ]; then
  dde-dock -r
fi
