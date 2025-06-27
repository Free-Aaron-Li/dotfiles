#!/bin/bash

# 代理地址
PROXY_URL="http://127.0.0.1:7897"
SOCKS_PROXY="127.0.0.1:7897"

# 环境变量文件
PROFILE_FILE="$HOME/.bashrc"  # 或 ~/.zshrc，根据你的 shell 环境选择

# 设置或清除代理
toggle_proxy() {
    if [[ "$1" == "enable" ]]; then
        echo "启用代理..."
        # 设置系统代理
        echo "export http_proxy=$PROXY_URL" >> $PROFILE_FILE
        echo "export https_proxy=$PROXY_URL" >> $PROFILE_FILE
        # 设置 SSH 代理
        mkdir -p ~/.ssh
        echo "Host *" > ~/.ssh/config
        echo "  ProxyCommand nc -x $SOCKS_PROXY %h %p" >> ~/.ssh/config
        echo "代理已启用。"
    elif [[ "$1" == "disable" ]]; then
        echo "禁用代理..."
        # 清除系统代理
        sed -i '/http_proxy/d' $PROFILE_FILE
        sed -i '/https_proxy/d' $PROFILE_FILE
        # 清除 SSH 代理
        rm -f ~/.ssh/config
        echo "代理已禁用。"
    else
        echo "未知操作：$1"
        exit 1
    fi
    source $PROFILE_FILE
}

# 主函数
case "$1" in
    on)
        toggle_proxy enable
        ;;
    off)
        toggle_proxy disable
        ;;
    *)
        echo "用法: $0 {on|off}"
        echo "  on  - 启用代理"
        echo "  off - 禁用代理"
        exit 1
        ;;
esac
