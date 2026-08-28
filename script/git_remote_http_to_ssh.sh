#!/bin/bash
# ======================================================================
# 脚本：git_remote_http_to_ssh.sh
# 功能：将 Git 远程仓库的 URL 从 HTTP(S) 转换为 SSH 格式。
#       默认处理 GitHub，但可轻松扩展至 GitLab、Bitbucket 等。
# 用法：./git_remote_http_to_ssh.sh [远程名称]
#       如果不指定远程名称，默认使用 "origin"。
# 示例：./git_remote_http_to_ssh.sh origin
# ======================================================================

set -euo pipefail

# ------------------------------------------------------------
# 配置区域（可根据需要修改）
# ------------------------------------------------------------
DEFAULT_REMOTE="origin"          # 默认远程仓库名称
SUPPORTED_HOSTS="github.com"     # 当前支持的托管平台，仅用于提示，实际转换由函数处理

# ------------------------------------------------------------
# 函数：将 HTTP(S) URL 转换为 SSH 格式
# 参数：$1 - 完整的远程 URL（如 https://github.com/user/repo.git）
# 输出：转换后的 SSH URL（如 git@github.com:user/repo.git）
# 返回：0 成功，1 失败
# ------------------------------------------------------------
convert_to_ssh() {
    local url="$1"
    local host path

    # 若已是 SSH 格式，直接返回原值
    if [[ "$url" =~ ^git@ ]]; then
        echo "$url"
        return 0
    fi

    # 尝试匹配 HTTP/HTTPS 格式
    if [[ "$url" =~ ^https?://([^/]+)/(.*)$ ]]; then
        host="${BASH_REMATCH[1]}"
        path="${BASH_REMATCH[2]}"
    else
        echo "错误：无法识别的 URL 格式 '$url'" >&2
        return 1
    fi

    # 确保路径以 .git 结尾（SSH 通常要求）
    if [[ "$path" != *.git ]]; then
        path="${path}.git"
    fi

    # --------------------------------------------------------
    # 扩展点：根据不同托管平台调整转换逻辑
    # 目前绝大多数平台（GitHub, GitLab, Bitbucket）都支持
    # git@<host>:<path> 格式，因此无需额外处理。
    # 若未来有特例，可在此添加 case 分支。
    # --------------------------------------------------------
    echo "git@${host}:${path}"
    return 0
}

# ------------------------------------------------------------
# 主程序
# ------------------------------------------------------------

# 1. 确定远程仓库名称
REMOTE_NAME="${1:-$DEFAULT_REMOTE}"

# 2. 检查是否在 Git 仓库内
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "错误：当前目录不是 Git 仓库，请在仓库根目录运行此脚本。" >&2
    exit 1
fi

# 3. 获取当前远程 URL
if ! current_url=$(git remote get-url "$REMOTE_NAME" 2>/dev/null); then
    echo "错误：远程仓库 '$REMOTE_NAME' 不存在。" >&2
    exit 1
fi

echo "当前远程 URL：$current_url"

# 4. 检查是否已是 SSH 格式
if [[ "$current_url" =~ ^git@ ]]; then
    echo "该远程 URL 已经是 SSH 格式，无需转换。"
    exit 0
fi

# 5. 检查是否属于 GitHub（或其他受支持平台），仅作警示
if [[ "$current_url" != *"github.com"* ]]; then
    echo "注意：当前远程 URL 似乎不属于 GitHub，但转换逻辑仍将尝试处理。"
    read -r -p "是否继续？(y/N) " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "操作已取消。"
        exit 0
    fi
fi

# 6. 生成新的 SSH URL
new_url=$(convert_to_ssh "$current_url") || exit 1
echo "新的 SSH URL：$new_url"

# 7. 最终确认
read -r -p "确认将远程 URL 更新为上述地址？(y/N) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "操作已取消。"
    exit 0
fi

# 8. 执行修改
git remote set-url "$REMOTE_NAME" "$new_url"
echo "✅ 远程 URL 已成功更新。"
echo "当前远程配置："
git remote -v
