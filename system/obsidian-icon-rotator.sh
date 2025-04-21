#!/bin/bash

# 用户桌面文件路径
USER_DESKTOP_FILE="$HOME/.local/share/applications/obsidian.desktop"
ICON_DIR="/opt/Obsidian/icons"

# 如果用户目录下没有桌面文件，则从系统复制
mkdir -p "$(dirname "$USER_DESKTOP_FILE")"
[ ! -f "$USER_DESKTOP_FILE" ] && \
cp /usr/share/applications/obsidian.desktop "$USER_DESKTOP_FILE"

# 随机选择图标（0-31）
icon_number=$(( RANDOM % 32 ))
icon_path="$ICON_DIR/${icon_number}.svg"

# 更新桌面文件
sed -i "s|^Icon=.*|Icon=$icon_path|" "$USER_DESKTOP_FILE"

# 更新桌面数据库
update-desktop-database "$HOME/.local/share/applications/"

# 确保 hicolor 主题的 index.theme 存在
HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
mkdir -p "$HICOLOR_DIR"
if [ ! -f "$HICOLOR_DIR/index.theme" ]; then
    cat > "$HICOLOR_DIR/index.theme" <<EOF
[Icon Theme]
Name=hicolor
Comment=Fallback theme for all icons
Directories=scalable/apps

[scalable/apps]
Size=48
Type=Scalable
MinSize=1
MaxSize=512
Context=Applications
EOF
fi

# 更新图标缓存
if hash gtk-update-icon-cache 2>/dev/null; then
  gtk-update-icon-cache -f "$HICOLOR_DIR"
fi

# 尝试通过 DDE Dock 刷新（Deepin V20+ 验证有效）
if [ -x "$(command -v dde-dock)" ]; then
  dde-dock -r
fi
