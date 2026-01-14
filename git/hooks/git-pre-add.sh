#!/bin/bash

# 切换到仓库根目录
repo_path=$(git rev-parse --show-toplevel)
cd "$repo_path" || exit 1

# 检查xmake是否可用
if ! command -v xmake >/dev/null 2>&1; then
  echo "❌ xmake 未安装，请确保你已安装 xmake！"
  exit 1
fi

# 删除旧的 CMakeLists.txt（确保没有缓存）
rm -f CMakeLists.txt

# 生成最新 CMakeLists.txt
if ! xmake project -k cmakelists >/dev/null 2>&1; then
  echo "❌ CMakeLists.txt 生成失败，请检查配置！"
  exit 1
fi

# 添加最新生成的 CMakeLists.txt
git add -f CMakeLists.txt

# 验证文件变更
if git diff --cached --quiet CMakeLists.txt; then
    echo "✅ CMakeLists.txt无变更"
else
    echo "✨ 已更新并暂存CMakeLists.txt"
fi

# 执行正常的 git add（传递所有参数）
git add "$@"
