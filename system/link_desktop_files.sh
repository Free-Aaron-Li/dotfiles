#!/bin/bash

# 定义函数：检查目标文件是否存在，如果存在则备份
backup_if_exists() {
    local target_file=$1
    if [[ -e "$target_file" ]]; then
        mv "$target_file" "${target_file}.bak"
        echo "备份文件：$target_file -> ${target_file}.bak"
    fi
}

# 一、硬连接创建
# 1. 创建硬链接，将 /home/aaron/.files/vim/.ideavimrc 链接到 /home/aaron/
source_file1="/home/aaron/.files/vim/.ideavimrc"
target_file1="/home/aaron/.ideavimrc"

# 检查源文件是否存在
if [[ -f "$source_file1" ]]; then
    # 检查目标文件是否存在，如果存在则备份
    backup_if_exists "$target_file1"
    # 创建硬链接
    ln "$source_file1" "$target_file1"
    echo "创建硬链接：$source_file1 -> $target_file1"
else
    echo "源文件不存在：$source_file1"
fi

# 2. 创建硬链接，将 /home/aaron/.files/kando 目录下的 config.json 和 menus.json 链接到 /home/aaron/.config/kando 目录下
source_dir2="/home/aaron/.files/kando"
target_dir2="/home/aaron/.config/kando"

# 检查目标目录是否存在，如果不存在则创建
if [[ ! -d "$target_dir2" ]]; then
    mkdir -p "$target_dir2"
    echo "创建目录：$target_dir2"
fi

# 遍历需要链接的文件
for file in config.json menus.json; do
    source_file="$source_dir2/$file"
    target_file="$target_dir2/$file"

    # 检查源文件是否存在
    if [[ -f "$source_file" ]]; then
        # 检查目标文件是否存在，如果存在则备份
        backup_if_exists "$target_file"
        # 创建硬链接
        ln "$source_file" "$target_file"
        echo "创建硬链接：$source_file -> $target_file"
    else
        echo "源文件不存在：$source_file"
    fi
done

# 二、软连接创建
# 定义源目录和目标目录
src_dir="/home/aaron/.files/DESKTOP"
dest_dir="/home/aaron/.local/share/applications"

# 检查目标目录是否存在，如果不存在则创建
# 冗余设计，通常该目录存在
if [[ ! -d "dest_dir" ]]; then
    mkdir -p "dest_dir"
    echo "创建目录：$dest_dir"
fi

# 遍历源目录中的所有.desktop文件
for src in "$src_dir"/*.desktop; do
    # 处理无匹配文件的情况
    [ -e "$src" ] || continue
    # 创建符号链接，强制覆盖已存在的链接
    ln -sf "$src" "$dest_dir/"
    echo "创建软链接：$src_dir -> $dest_dir"
done

echo "软链接创建完成。"

