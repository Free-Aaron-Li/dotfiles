#!/bin/bash
# modern-copy - 多文件/目录拷贝工具（多线程压缩传输版）

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认压缩程序及参数（可调整）
COMPRESSOR="zstd"
COMPRESS_OPTS="-T0 -3"        # 多线程，平衡压缩级别
DECOMPRESS_OPTS="-dc"         # 解压到标准输出

usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options] source1 [source2 ...] destination"
    echo "Copy multiple files/directories to destination with multi-threaded compressed transfer."
    echo "Options:"
    echo "  -l LEVEL   Set compression level (1=fast, 19=small, default 3 for zstd)"
    echo "  -p PROG    Use specified compressor (zstd, pigz, gzip; default zstd)"
    echo "  -h, --help Show this help"
    exit 1
}

# 解析选项
while getopts "l:p:h" opt; do
    case $opt in
        l) COMPRESS_OPTS="-T0 -$OPTARG" ;;
        p) COMPRESSOR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

# 检查参数数量
if [ $# -lt 2 ]; then
    usage
fi

# 提取目标（最后一个参数）
dest="${@: -1}"
# 提取所有源（除最后一个外）
sources=("${@:1:$#-1}")

# 检查每个源是否存在
for src in "${sources[@]}"; do
    if [ ! -e "$src" ]; then
        echo -e "${RED}Error: source '$src' does not exist.${NC}"
        exit 1
    fi
done

# 检查目标是否存在，不存在则尝试创建
if [ ! -d "$dest" ]; then
    echo -e "${YELLOW}Destination '$dest' does not exist. Creating...${NC}"
    mkdir -p "$dest" || { echo -e "${RED}Failed to create destination directory.${NC}"; exit 1; }
fi

# 检查依赖命令
for cmd in tar pv $COMPRESSOR; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed.${NC}"
        exit 1
    fi
done

# 计算所有源的总大小（字节）
echo -e "${BLUE}Calculating total size...${NC}"
total_size=0
for src in "${sources[@]}"; do
    size=$(du -sb "$src" | awk '{print $1}')
    total_size=$((total_size + size))
done
echo -e "Total size: $(numfmt --to=iec $total_size)"

# 构建 tar 参数（保留顶层目录）
tar_args=()
for src in "${sources[@]}"; do
    src_abs=$(realpath "$src")          # 获取绝对路径
    parent=$(dirname "$src_abs")
    base=$(basename "$src_abs")
    tar_args+=(-C "$parent" "$base")     # 切换到父目录，只添加 basename
done

# 开始压缩传输
echo -e "${BLUE}Starting compressed copy...${NC}"
echo -e "Compressor: $COMPRESSOR $COMPRESS_OPTS"   # 这里已修正

# 管道：tar 打包 → pv 显示进度 → 压缩 → 解压 → 目标目录 tar 解包
tar -c "${tar_args[@]}" | \
    pv -s $total_size | \
    $COMPRESSOR $COMPRESS_OPTS | \
    ( cd "$dest" && $COMPRESSOR $DECOMPRESS_OPTS | tar -x )

# 检查结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Copy completed successfully.${NC}"
else
    echo -e "${RED}Copy failed.${NC}"
    exit 1
fi
