#!/bin/bash
# modern-copy - 多文件/目录复制工具，带进度条

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}Usage:${NC} $0 source1 [source2 ...] destination"
    echo "Copy multiple files/directories to destination with progress bar."
    echo "Requires rsync (version >= 3.1.0 recommended for overall progress)."
    exit 1
}

# 显示帮助
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

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

# 检查rsync是否安装
if ! command -v rsync &> /dev/null; then
    echo -e "${RED}Error: rsync is not installed.${NC}"
    echo "Please install rsync (e.g., sudo apt install rsync)."
    exit 1
fi

# 检测rsync是否支持 --info=progress2（整体进度条）
if rsync --help 2>&1 | grep -q "info=progress2"; then
    progress_opt="--info=progress2"
    echo -e "${GREEN}Using overall progress bar (rsync ≥ 3.1.0).${NC}"
else
    progress_opt="--progress"
    echo -e "${YELLOW}rsync too old, falling back to per-file progress.${NC}"
fi

# 开始复制
echo -e "${BLUE}Starting copy...${NC}"
rsync -ahv --stats $progress_opt "${sources[@]}" "$dest/"

# 检查结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Copy completed successfully.${NC}"
else
    echo -e "${RED}Copy failed.${NC}"
    exit 1
fi
