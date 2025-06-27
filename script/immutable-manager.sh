#!/bin/bash

# Deepin v25 Beta 磐石系统管理脚本-By WqlSoft
# 功能：1.解除磐石系统 2.恢复磐石系统 3.查询磐石系统状态 4.重启电脑
# 250528  加入目录可写测试
# 250528  系统分区为自动分区，在vm虚拟机中测试可用。手动分区未测试！！！

# 检查是否安装了zenity
if ! command -v zenity &> /dev/null; then
    echo "错误：需要安装zenity才能运行此脚本"
    echo "请执行：sudo apt install zenity"
    exit 1
fi

# 颜色定义（用于终端输出，zenity不使用这些）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

# 检查目录是否可写（使用sudo）
check_writable() {
    if sudo [ -w "$1" ]; then
        echo "可写"
    else
        echo "只读"
    fi
}

# 获取磐石状态信息
get_status_info() {
    deepin-immutable-writable status | sed -e 's/Enable/启用状态/g' -e 's/Booted/启动状态/g' -e 's/Whitelist/白名单/g' -e 's/ClearAfterReboot/重启后清除/g' -e 's/CleanData/清理数据/g' -e 's/OverlayDirs/挂载目录/g' -e 's/OverlayAllDirs/挂载所有目录/g' -e 's/false/否/g' -e 's/true/是/g'
}

# 显示状态信息
show_status() {
    status_info=$(get_status_info)
    dir_info=$(echo -e "\n关键目录写入状态:\n/usr: $(check_writable /usr)\n/etc: $(check_writable /etc)\n/opt: $(check_writable /opt)\n/boot: $(check_writable /boot)\n/var: $(check_writable /var)")
    zenity --height=500 --info --title="磐石系统状态" --text="当前系统磐石状态:\n${status_info}\n${dir_info}" --width=500
}

# 主菜单
main_menu() {
    while true; do
        choice=$(zenity --list \
            --title="Deepin v25 Beta 磐石系统管理工具" \
            --text="请选择要执行的操作:" \
            --column="选项" --column="说明" \
            "1" "解除磐石系统 (/usr目录可写)" \
            "2" "恢复磐石系统 (/usr目录只读)" \
            "3" "查询磐石系统状态" \
            "4" "重启电脑" \
            "5" "退出" \
            --width=500 --height=500)
        
        if [ $? -ne 0 ]; then
            exit 0
        fi

        case $choice in
            1)
                zenity --height=500 --question --title="确认操作" --text="确定要解除磐石系统吗？" --width=300
                if [ $? -eq 0 ]; then
                    (
                        echo "10"
                        echo "# 正在解除磐石系统..."
                        sudo deepin-immutable-writable enable -a -y
                        echo "100"
                        echo "# 操作完成，请重启系统使更改生效！"
                    ) | zenity --height=500 --progress --title="操作中" --text="正在处理..." --percentage=0 --auto-close
                    if [ $? -ne 0 ]; then
                        zenity --height=500 --error --text="操作可能未完全完成" --width=300
                    fi
                fi
                ;;
            2)
                zenity --height=500 --question --title="确认操作" --text="确定要恢复磐石系统吗？" --width=300
                if [ $? -eq 0 ]; then
                    (
                        echo "10"
                        echo "# 正在恢复磐石系统..."
                        sudo deepin-immutable-writable disable -y
                        echo "100"
                        echo "# 操作完成，请重启系统使更改生效！"
                    ) | zenity --height=500 --progress --title="操作中" --text="正在处理..." --percentage=0 --auto-close
                    if [ $? -ne 0 ]; then
                        zenity --height=500 --error --text="操作可能未完全完成" --width=300
                    fi
                fi
                ;;
            3)
                show_status
                ;;
            4)
                zenity --height=500 --question --title="确认重启" --text="确定要重启电脑吗？" --width=300
                if [ $? -eq 0 ]; then
                    sudo reboot
                fi
                ;;
            5)
                exit 0
                ;;
            *)
                zenity --height=500 --error --text="无效的选项" --width=200
                ;;
        esac
    done
}

# 初始显示状态信息
show_status

# 显示主菜单
main_menu
