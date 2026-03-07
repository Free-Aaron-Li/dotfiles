#!/bin/bash
# 迁移 virtual 目录（支持通用配置和进度显示）

# ============== 用户配置区域 ==============
# 本地源目录
LOCAL_VIRTUAL="/home/leorio/virtual"

# 外部设备挂载点
EXTERNAL_BASE="/run/media/leorio/ff88824a-ef6d-044f-b812-c98469eb8b35"
EXTERNAL_VIRTUAL="$EXTERNAL_BASE/virtual"

# 排除目录（不迁移这些目录，保留在本地）
EXCLUDE_DIRS=("share" "cache" "temp")  # 添加需要排除的目录名

# 日志文件
LOG_FILE="/tmp/migrate-virtual-$(date +%Y%m%d_%H%M%S).log"
VERIFY_LOG="/tmp/migrate-verify-$(date +%Y%m%d_%H%M%S).log"

# ============== 进度显示配置 ==============
PROGRESS_WIDTH=50  # 进度条宽度
PROGRESS_CHAR="#"
REMAIN_CHAR="-"

# ============== 函数定义 ==============

# 记录日志函数
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# 进度条显示函数
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percentage=$((current * 100 / total))
    local filled=$((current * PROGRESS_WIDTH / total))
    local empty=$((PROGRESS_WIDTH - filled))
    
    # 构建进度条
    local progress_bar="["
    for ((i=0; i<filled; i++)); do
        progress_bar+="$PROGRESS_CHAR"
    done
    for ((i=0; i<empty; i++)); do
        progress_bar+="$REMAIN_CHAR"
    done
    progress_bar+="]"
    
    # 显示进度条（使用回车符覆盖同一行）
    printf "\r%-${PROGRESS_WIDTH}s %3d%% %s" "$progress_bar" "$percentage" "$message"
    
    # 如果是最后一项，换行
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# 检查是否在排除列表中
is_excluded() {
    local item_name="$1"
    for excluded in "${EXCLUDE_DIRS[@]}"; do
        if [ "$item_name" = "$excluded" ]; then
            return 0  # 在排除列表中
        fi
    done
    return 1  # 不在排除列表中
}

# 验证两个目录内容是否一致
verify_directories() {
    local src="$1"
    local dst="$2"
    local item_name="$3"
    local current=$4
    local total=$5
    
    show_progress $current $total "验证: $item_name"
    
    # 检查目标目录是否存在
    if [ ! -d "$dst" ]; then
        log "  错误: 目标目录不存在"
        return 1
    fi
    
    # 统计文件数量
    local src_count=$(find "$src" -type f 2>/dev/null | wc -l)
    local dst_count=$(find "$dst" -type f 2>/dev/null | wc -l)
    
    if [ "$src_count" -ne "$dst_count" ]; then
        log "  文件数量不匹配: 源=$src_count, 目标=$dst_count"
        return 1
    fi
    
    # 比较总大小
    local src_size=$(du -sb "$src" 2>/dev/null | cut -f1)
    local dst_size=$(du -sb "$dst" 2>/dev/null | cut -f1)
    
    if [ "$src_size" != "$dst_size" ]; then
        log "  总大小不匹配: 源=$src_size, 目标=$dst_size"
        return 1
    fi
    
    # 使用rsync的dry-run模式检查差异
    local diff_output=$(rsync -avn --delete --itemize-changes "$src/" "$dst/" 2>&1 | grep -E "^[<>c\.]|^sent|^total")
    
    if echo "$diff_output" | grep -q -E "^[<>c]"; then
        log "  发现差异:"
        echo "$diff_output" | head -5 | while read line; do
            log "    $line"
        done
        return 1
    fi
    
    log "  验证通过: $item_name"
    return 0
}

# 迁移目录
migrate_directory() {
    local item="$1"
    local item_name="$2"
    local current=$3
    local total=$4
    
    # 如果已经是符号链接，跳过
    if [ -L "$item" ]; then
        show_progress $current $total "跳过符号链接: $item_name"
        log "跳过符号链接: $item_name"
        return 0
    fi
    
    # 检查目标目录是否已存在
    if [ -d "$EXTERNAL_VIRTUAL/$item_name" ]; then
        show_progress $current $total "检查已迁移: $item_name"
        log "检查已迁移目录: $item_name"
        
        # 验证目录是否已完整迁移
        if verify_directories "$item" "$EXTERNAL_VIRTUAL/$item_name" "$item_name" $current $total; then
            show_progress $current $total "使用已迁移: $item_name"
            log "目录已完整迁移，使用现有数据: $item_name"
            
            # 删除本地副本
            rm -rf "$item"
            
            # 创建符号链接
            ln -sf "$EXTERNAL_VIRTUAL/$item_name" "$LOCAL_VIRTUAL/$item_name"
            
            log "完成: $item_name (使用已迁移数据)"
            return 0
        else
            show_progress $current $total "重新迁移: $item_name"
            log "验证失败，需要重新迁移: $item_name"
        fi
    fi
    
    # 使用rsync迁移
    show_progress $current $total "开始迁移: $item_name"
    log "开始迁移目录: $item_name"
    
    rsync -av --checksum --progress --partial \
          --log-file="$VERIFY_LOG" \
          "$item/" "$EXTERNAL_VIRTUAL/$item_name/"
    
    if [ $? -eq 0 ]; then
        show_progress $current $total "验证迁移: $item_name"
        log "迁移完成，开始最终验证: $item_name"
        
        # 最终验证
        if verify_directories "$item" "$EXTERNAL_VIRTUAL/$item_name" "$item_name" $current $total; then
            # 删除本地副本
            rm -rf "$item"
            
            # 创建符号链接
            ln -sf "$EXTERNAL_VIRTUAL/$item_name" "$LOCAL_VIRTUAL/$item_name"
            
            show_progress $current $total "迁移完成: $item_name"
            log "迁移完成: $item_name"
            return 0
        else
            show_progress $current $total "验证失败: $item_name"
            log "最终验证失败，保留本地副本: $item_name"
            return 1
        fi
    else
        show_progress $current $total "迁移失败: $item_name"
        log "迁移失败: $item_name"
        return 1
    fi
}

# 迁移文件
migrate_file() {
    local item="$1"
    local item_name="$2"
    
    log "处理文件: $item_name"
    
    # 检查目标文件是否已存在且相同
    if [ -f "$EXTERNAL_VIRTUAL/$item_name" ]; then
        if cmp -s "$item" "$EXTERNAL_VIRTUAL/$item_name"; then
            log "  -> 文件已存在且内容相同"
            rm -f "$item"
            ln -sf "$EXTERNAL_VIRTUAL/$item_name" "$LOCAL_VIRTUAL/$item_name"
            log "  -> 完成: $item_name (使用已存在文件)"
            return 0
        fi
    fi
    
    # 迁移文件
    cp -p "$item" "$EXTERNAL_VIRTUAL/"
    if cmp -s "$item" "$EXTERNAL_VIRTUAL/$item_name"; then
        rm -f "$item"
        ln -sf "$EXTERNAL_VIRTUAL/$item_name" "$LOCAL_VIRTUAL/$item_name"
        log "  -> 完成: $item_name"
        return 0
    else
        log "  -> 错误: $item_name 文件复制后验证失败"
        return 1
    fi
}

# ============== 主程序开始 ==============

log "=== 开始迁移流程 ==="
log "本地目录: $LOCAL_VIRTUAL"
log "外部设备: $EXTERNAL_VIRTUAL"
log "排除目录: ${EXCLUDE_DIRS[*]}"
log "日志文件: $LOG_FILE"
log "验证日志: $VERIFY_LOG"

# 确保外部设备已挂载
if [ ! -d "$EXTERNAL_BASE" ]; then
    log "错误：外部设备未挂载在 $EXTERNAL_BASE"
    exit 1
fi

# 创建外部设备目录
mkdir -p "$EXTERNAL_VIRTUAL"

# 清空验证日志
> "$VERIFY_LOG"

# 收集需要处理的目录和文件
log "扫描目录内容..."
declare -a dirs_to_migrate=()
declare -a files_to_migrate=()

for item in "$LOCAL_VIRTUAL"/*; do
    item_name=$(basename "$item")
    
    # 检查是否在排除列表中
    if is_excluded "$item_name"; then
        log "跳过排除目录/文件: $item_name"
        continue
    fi
    
    if [ -d "$item" ]; then
        dirs_to_migrate+=("$item")
    elif [ -f "$item" ]; then
        files_to_migrate+=("$item")
    fi
done

total_dirs=${#dirs_to_migrate[@]}
total_files=${#files_to_migrate[@]}
total_items=$((total_dirs + total_files))

log "找到 $total_dirs 个目录和 $total_files 个文件需要迁移"
echo ""

# 迁移目录（显示进度条）
if [ $total_dirs -gt 0 ]; then
    echo "开始迁移目录:"
    current=0
    for item in "${dirs_to_migrate[@]}"; do
        current=$((current + 1))
        item_name=$(basename "$item")
        
        # 检查是否是符号链接（可能在上一次迁移中已处理）
        if [ -L "$item" ]; then
            show_progress $current $total_dirs "跳过符号链接: $item_name"
            continue
        fi
        
        migrate_directory "$item" "$item_name" $current $total_dirs
    done
    echo ""
fi

# 迁移文件（不显示进度条，因为文件通常较少）
if [ $total_files -gt 0 ]; then
    echo "开始迁移文件:"
    for item in "${files_to_migrate[@]}"; do
        item_name=$(basename "$item")
        
        # 检查是否是符号链接
        if [ -L "$item" ]; then
            log "跳过符号链接文件: $item_name"
            continue
        fi
        
        migrate_file "$item" "$item_name"
        echo "  ✓ $item_name"
    done
    echo ""
fi

# 显示迁移结果
echo "==================== 迁移完成 ===================="
log "=== 迁移完成 ==="

echo "本地目录内容 ($LOCAL_VIRTUAL):"
ls -la "$LOCAL_VIRTUAL/" 2>/dev/null | while read line; do
    echo "  $line"
done

echo ""
echo "外部设备内容 ($EXTERNAL_VIRTUAL):"
if [ -d "$EXTERNAL_VIRTUAL" ]; then
    ls -la "$EXTERNAL_VIRTUAL/" 2>/dev/null | head -20 | while read line; do
        echo "  $line"
    done
    if [ $(ls -la "$EXTERNAL_VIRTUAL/" 2>/dev/null | wc -l) -gt 23 ]; then
        echo "  ... (更多内容请查看目录)"
    fi
else
    echo "  (目录不存在)"
fi

echo ""
echo "日志文件: $LOG_FILE"
echo "验证日志: $VERIFY_LOG"
echo "排除目录: ${EXCLUDE_DIRS[*]} (保留在本地)"
log "迁移流程结束"
