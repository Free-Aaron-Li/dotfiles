#!/bin/bash
# 文件名: incremental_backup.sh
# 描述: 将指定目录增量备份到 U 盘

# 配置部分（根据实际情况修改）
SOURCE_DIR="/home/leorio/virtual/share"          # 要备份的源目录
USB_MOUNT_POINT="/run/media/leorio/8B5B-8E06"           # U盘挂载点
BACKUP_DIR_NAME="share"                # U盘上的备份目录名

# 目标完整路径
DEST_DIR="${USB_MOUNT_POINT}/${BACKUP_DIR_NAME}"

# 检查 U 盘是否已挂载
if ! mountpoint -q "$USB_MOUNT_POINT"; then
    echo "错误: U盘未挂载在 $USB_MOUNT_POINT"
    echo "请先挂载 U盘，例如: sudo mount /dev/sdX1 $USB_MOUNT_POINT"
    exit 1
fi

# 创建目标目录（如果不存在）
mkdir -p "$DEST_DIR"

# 执行 rsync 增量备份
# -a : 归档模式，保留权限、时间戳，递归拷贝
# -v : 显示详细信息
# --delete : 删除目标端源端不存在的文件（保持完全镜像）
# 若不需要删除，可去掉 --delete
rsync -av --delete "$SOURCE_DIR/" "$DEST_DIR/"

# 检查 rsync 执行结果
if [ $? -eq 0 ]; then
    echo "备份成功完成于 $(date)"
else
    echo "备份过程中出现错误，请检查"
    exit 2
fi
