#!/bin/bash
# 通用拷贝脚本（带诊断功能）
# 将 .cppm（或指定后缀）重命名为 .txt，并拷贝 CMakeLists.txt 和 .cpp 到 txt/（扁平化）
# 忽略 cmake-build-* 目录

set -euo pipefail

# 默认文件扩展名（可修改）
CPPM_EXT=".cppm"   # 若实际为 .cppm，请改为 ".cppm"

show_help() {
    cat << EOF
用法: $0 [选项] [PROJECT_DIR]

选项:
  -e EXT       指定 .cppm 文件扩展名（默认 .cppm）
  -v           详细模式，输出每个找到的文件
  --dry-run    仅显示将要执行的操作，不实际拷贝
  -h, --help   显示此帮助

参数:
  PROJECT_DIR  项目根目录（默认当前目录）
EOF
}

VERBOSE=0
DRY_RUN=0
PROJECT_DIR="$(pwd)"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -e)
            CPPM_EXT="$2"
            shift 2
            ;;
        -v)
            VERBOSE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

if [ ! -d "$PROJECT_DIR" ]; then
    echo "错误: 目录 '$PROJECT_DIR' 不存在" >&2
    exit 1
fi

cd "$PROJECT_DIR"
ROOT_DIR="$(pwd)"
TARGET_DIR="${ROOT_DIR}/txt"

echo "项目根目录: $ROOT_DIR"
echo "目标目录: $TARGET_DIR"
echo "扩展名: $CPPM_EXT"
if [ "$DRY_RUN" -eq 1 ]; then
    echo "*** 预览模式（不实际拷贝） ***"
fi

mkdir -p "$TARGET_DIR"

# 通用拷贝函数
# $1: 查找模式 (如 "*.cppm")
# $2: 描述
# $3: 是否重命名为 .txt (true/false)
copy_files() {
    local pattern="$1"
    local desc="$2"
    local rename="$3"
    local count=0
    echo "开始查找 $desc 文件..."

    # 构建 find 命令，排除 cmake-build-*
    # 注意：-path 匹配需要使用相对路径，加 "./" 前缀
    local find_cmd="find . -type f -name \"$pattern\" -not -path \"./cmake-build-*/*\""

    if [ "$VERBOSE" -eq 1 ]; then
        echo "执行命令: $find_cmd"
    fi

    while IFS= read -r -d '' file; do
        relpath="${file#./}"   # 去掉开头的 './'
        base="$(basename "$file")"
        
        # 构建目标文件名
        if [ "$rename" = "true" ]; then
            dest_base="${base%.*}.txt"   # 替换扩展名为 .txt
        else
            dest_base="$base"
        fi

        # 目标完整路径（扁平化）
        dest="${TARGET_DIR}/$dest_base"

        # 若目标已存在，添加原目录前缀（用下划线替换斜杠）
        if [ -e "$dest" ]; then
            dirpart="$(dirname "$relpath")"
            if [ "$dirpart" != "." ] && [ -n "$dirpart" ]; then
                prefix="${dirpart//\//_}_"   # 如 src/sub -> src_sub_
                if [ "$rename" = "true" ]; then
                    dest="${TARGET_DIR}/${prefix}${base%.*}.txt"
                else
                    dest="${TARGET_DIR}/${prefix}$base"
                fi
            fi
        fi

        # 显示操作
        if [ "$DRY_RUN" -eq 1 ]; then
            echo "[DRY-RUN] 将拷贝: $file -> $dest"
        else
            mkdir -p "$(dirname "$dest")"
            cp "$file" "$dest"
            if [ "$VERBOSE" -eq 1 ]; then
                echo "复制: $file -> $dest"
            fi
        fi
        ((count++))
    done < <(eval "$find_cmd" -print0)

    echo "共找到并处理 $count 个 $desc 文件。"
}

# 执行拷贝
copy_files "*$CPPM_EXT" ".cppm 文件" "true"
copy_files "CMakeLists.txt" "CMakeLists.txt" "false"
copy_files "*.cpp" ".cpp 文件" "false"

if [ "$DRY_RUN" -eq 0 ]; then
    echo "所有拷贝完成！目标目录: $TARGET_DIR"
else
    echo "预览结束。"
fi
