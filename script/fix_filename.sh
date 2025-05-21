#!/bin/bash

# 遍历所有输入的文件名参数
for file in "$@"; do
    # 获取文件名和目录路径
    dir=$(dirname "$file")
    filename=$(basename "$file")
    
    # 核心编码转换：latin1 -> gbk
    newname=$(echo "$filename" | iconv -t latin1 | iconv -f gbk)
    
    # 检查转换是否成功（非空）
    if [ -n "$newname" ] && [ "$newname" != "$filename" ]; then
        # 处理文件名重复问题
        if [ -e "$dir/$newname" ]; then
            # 生成随机后缀（5位数字）
            suffix=$((RANDOM % 100000))
            newname="${newname%.*}_$suffix.${newname##*.}"
        fi
        
        # 重命名文件
        mv -v "$file" "$dir/$newname"
        echo "已修复: $filename → $newname"
    else
        echo "跳过: $filename（无法修复或无需修复）"
    fi
done
