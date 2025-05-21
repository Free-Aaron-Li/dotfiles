#!/bin/bash

OBSIDIAN_SOURCE="/home/aaron/Documents/obsidian"
OBSIDIAN_DESTINATION="/media/aaron/Backup/obsidian_backup"

# 使用 rsync 进行同步（增量备份更高效）
rsync -avh --delete "$OBSIDIAN_SOURCE/" "$OBSIDIAN_DESTINATION/"
