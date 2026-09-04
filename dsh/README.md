# DSH Harness 脚本与运维统一规划

> 本目录是 DeepSeek Harness（DSH）相关的**全部脚本与运维配置的唯一权威位置**。
> 归属 dotfiles 仓库（`~/.files`），随 git 版本管理，换机可恢复。
> 建立日期：2026-09-04

## 目录结构

```
~/.files/dsh/
├── README.md            ← 本文件（统一规划与索引）
├── bin/                 ← 全部可执行脚本（真实文件）
│   ├── dsh-web.sh           dsh web 启动包装（launchd 托管用）
│   ├── dsh-web-migrate.sh   nohup → launchd 一键迁移脚本
│   ├── dsh-plugin-updater.sh  插件安全自动更新管线（dp-update）
│   ├── dsh-remote-fwd.py    easytier 虚拟 IP → 本机 3080 转发器
│   └── hindsight-daemon.sh  Hindsight daemon 启动包装
└── (plists/ 可扩展：launchd 配置模板的 git 化副本)
```

## 软链接约定

**真实文件一律放 `~/.files/dsh/bin/`，对外暴露用软链接**：

| 脚本（真实位置） | 软链接（对外） | 被谁引用 |
|---|---|---|
| `bin/dsh-web.sh` | `~/.local/bin/dsh-web.sh` | launchd `com.user.dsh-web` |
| `bin/dsh-web-migrate.sh` | `~/.local/bin/dsh-web-migrate.sh` | 手动（终端） |
| `bin/dsh-plugin-updater.sh` | `~/.local/bin/dsh-plugin-updater.sh` | launchd `com.user.dsh-plugin-updater` + zsh `dp-update` |
| `bin/dsh-remote-fwd.py` | `~/.local/bin/dsh-remote-fwd.py` | launchd `com.user.dsh-remote-fwd` + zsh `fwd-start` |
| `bin/hindsight-daemon.sh` | `~/.local/bin/hindsight-daemon.sh` | launchd `com.user.hindsight.daemon` |

> `~/.local/bin` 在 PATH 中（zshrc 第 77 行）。launchd 与 zsh 均跟随软链，
> 指向不变，因此**移动真实文件不影响任何已配置服务**。
> 新增脚本流程：文件放 `~/.files/dsh/bin/` → `ln -sf` 到 `~/.local/bin/` → git 提交。

## launchd 托管服务一览（都引用上面的软链）

| LaunchAgent | 脚本 | 调度/策略 | 说明 |
|---|---|---|---|
| `com.user.dsh-web` | `dsh-web.sh` | RunAtLoad + KeepAlive | dsh web 完全后台（ghostty 退出无影响）|
| `com.user.dsh-plugin-updater` | `dsh-plugin-updater.sh --auto` | 每日 03:00 | 插件安全自动更新（隔离测试→更新→回滚）|
| `com.user.dsh-remote-fwd` | `dsh-remote-fwd.py` | RunAtLoad + KeepAlive | 10.10.10.22:3080 → 127.0.0.1:3080 |
| `com.user.hindsight.daemon` | `hindsight-daemon.sh` | RunAtLoad + KeepAlive | Hindsight API（端口 9077）|
| `com.user.ollama.serve` | （ollama 二进制） | RunAtLoad + KeepAlive | 本地 ollama |

## 用户命令速查（zsh 函数，定义在 ~/.zshrc）

| 命令 | 作用 |
|---|---|
| `dp-start` / `dp-stop` / `dp-status` | launchd 托管 dsh web 的 起/停/查 |
| `dp-update` / `dp-update --auto` / `dp-update --check` | 插件更新：交互 / 全自动 / 只检测 |
| `fwd-start` / `fwd-stop` | easytier 转发器手动起停 |

## 配套数据与日志（非脚本，运行时生成）

| 项 | 位置 |
|---|---|
| 插件更新报告 | `~/.dsh/plugin-update-report.md`（每日首会话汇报依据）|
| 更新快照 | `~/.dsh/plugin-update-snap/` |
| dsh web 日志 | `/tmp/dsh-web.log` |
| 更新管线日志 | `/tmp/dsh-plugin-updater.log` |
| dsh-config-manager | `~/.dsh/dsh-config-manager/`（备份 exports/snapshots/vault）|
| Hindsight 配置 | `~/.hindsight/profiles/coding-agent.env` |

## 相关文档

- 全局配置清单（含密钥位置、重建步骤）：`ecas 工作区 docs/harness-global-config.md`
- 全局技能：`~/.agents/skills/`（configure-remote-web-ui / configure-hindsight-local-llm / configure-ticktick-mcp / dsh-plugin-update-report / global-knowledge-convention 等）

## 维护约定

1. **改脚本**：编辑 `~/.files/dsh/bin/` 下的真实文件（勿改软链指向处内容编辑器误存）
2. **加脚本**：放入 bin/ → 软链 → 更新本 README 表格 → `git -C ~/.files commit`
3. **launchd 变更**：改 plist 后 `launchctl bootout` + `bootstrap`（或 kickstart -k 重启）
4. **换机恢复**：clone `~/.files` → 重建软链 → 重载全部 plist
