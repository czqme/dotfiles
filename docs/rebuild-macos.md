# macOS 恢复约定

目标：重装后通过 chezmoi 恢复工作环境，重新连接外盘中的长期数据。
SSH 已按此约定迁移；其他数据尚未全部迁移。

## 数据放在哪里

| 内容 | 位置 | 恢复方式 |
| --- | --- | --- |
| Shell、Git、编辑器等无密钥配置 | chezmoi 仓库 | `chezmoi apply` |
| 软件清单 | `Brewfile-core` / `Brewfile` | `brew bundle install` |
| 运行时与全局开发工具清单 | mise 配置 | `mise install` |
| Git 项目 | 现有 `/Volumes/Vault/dev/pj` | 保留完整目录，并推送应保留的分支到对应 GitHub 仓库 |
| 项目 `.env`、数据库、上传内容和私人输入 | 项目外盘目录或独立加密存储 | 单独备份；不因项目上 GitHub 而加入 Git |
| AI 会话、附件及应用持久数据 | 建议 `/Volumes/Vault/mac-state/<tool>` | 使用工具支持的数据目录，或经验证的目录链接 |
| 私钥、恢复码、令牌 | 密码管理器或加密存储 | 重装后取回或重新登录 |
| 缓存、依赖、可下载模型、编译产物 | 可留系统盘；大文件也可放外盘 | 重新生成或下载 |

不把整个 Home、`~/Library` 或 `~/.config` 链接到外盘。
先拆分配置、凭据、运行状态；混合目录必要时整体放外盘，只把无敏感内容的配置模板加入 chezmoi。
应用沙盒目录及钥匙串不强行重定向。

`Brewfile` 是完整软件清单，`Brewfile-core` 是基础工作环境。完整清单中的 App Store
应用可能需要先登录。GUI 应用继续按用户自己的方式检查和管理。
`~/.homebrew/brew.env` 将 `brew bundle dump` 限定为 tap、brew、cask 和 mas；
不导出 VS Code 扩展、Go、uv、Cargo、npm、Krew、Flatpak 或 WinGet 包。
`~/.config/homebrew/brew.env` 链接到同一份配置，兼容 `XDG_CONFIG_HOME=~/.config`。
mise 当前使用 `latest`，所以能重建工具种类，但不是固定版本复现；项目应自行固定所需版本。

## 新系统恢复顺序

1. 挂载 Vault，确认卷名及需要的数据目录正确，不要在未挂载时创建 `/Volumes/Vault`。
2. 使用保留的完整 dotfiles 仓库副本，或从 GitHub 克隆已推送版本。
   本地未提交修改不会出现在新克隆中。
3. 在仓库内运行 `bash scripts/restore-macos.sh`；需要全部应用时加 `--apps`。
4. 完成 GitHub、AI 工具、密码管理器等登录，以及必要的 macOS 自动化、辅助功能、
   屏幕录制等授权。仅向需要的工具授予权限。
5. 在首次启动相关工具前，逐项恢复外盘数据连接。安装工具可能已生成默认目录，
   此时先改名保留，不能直接覆盖或合并数据库。
6. 验证旧会话可打开、项目可构建、凭据可用。之后再清理旧副本。
7. 运行 `bash scripts/check-rebuild.sh`，处理报告并记录尚需手动恢复的项目。

恢复脚本会触发现有 chezmoi 安装脚本，包括 Homebrew、iTerm2 和 Oh My Zsh 外部资源。
它不会迁移数据，但会恢复已登记的链接（目前包括 SSH）。未在全新 macOS 上完成恢复演练前，不声称一键恢复已验证。

## SSH

- `~/.ssh` 链接到 `/Volumes/Vault/mac-state/ssh`，由仓库中的 `symlink_dot_ssh` 管理。
- 密钥、SSH 配置和 known_hosts 只保存在外盘，仓库里仅有链接地址。
- `~/.ssh/agent` 链接到当前用户的 `~/.local/state/ssh-agent`，运行时 socket 留在系统盘。
  恢复前置脚本会创建本地运行目录，不会复制旧 socket。
- 先挂载 Vault 并确认 SSH 数据存在，再运行恢复脚本。恢复不会生成或覆盖密钥。
- 如果新系统用户名变化，需要先调整外盘 `ssh/agent` 链接到新用户的本地运行目录；
  前置检查会拒绝不匹配的路径。
- 原系统盘文件保留在 `~/.ssh.local-backup-<时间>`，验证连接成功后再自行清理。
- 迁移时 Vault 未启用磁盘加密，并处于忽略所有权状态。已设置目录 700、私钥和配置 600，
  但这不等于磁盘加密。启用磁盘所有权需要管理员权限，尚未完成。

## 持久数据迁移方式

每个工具单独执行：退出工具和后台进程 → 复制至外盘 → 比较副本 → 改名保留原目录 →
设置工具支持的路径或创建链接 → 启动并验证 → 最后清理旧副本。

Codex 的目标可采用 `~/.codex` → `/Volumes/Vault/mac-state/codex`，但本仓库当前没有创建这个链接。
先保留本次重装前的完整备份，迁移后验证聊天与附件。不要把它的认证文件或整个会话目录加入 Git。
其他 AI 工具遵循同样原则，工具升级后仍需检查是否产生了新的本地数据位置。

只在交互式 shell 设置环境变量，未必影响从 Finder 启动的桌面应用。应使用应用支持的设置，
或在应用支持且验证通过时使用目录链接。外盘未挂载时不启动依赖它的数据服务。

外盘上的唯一副本是工作数据，不是备份；重要持久数据还需要另一份可恢复副本。

## 日常工作规则

- 新建项目默认放在 `/Volumes/Vault/dev/pj`。临时实验可放 `/tmp`，要保留时及时迁出。
- 安装长期使用的工具时，同步更新 Brewfile 或 mise；机器相关临时工具不必永久纳入。
- 修改长期配置时，同步更新 chezmoi 并检查 diff；不要只改目标文件。
- 需要保留的项目更改及时提交、推送到正确的 GitHub 仓库。公开/私有属性按项目确定。
  推送前检查暂存内容，避免上传 `.env`、私人输入、数据库及认证材料。
- 不自动执行 `git add .`、自动公开仓库或无差别推送全部仓库。
- 只有 Git 跟踪并推送的内容才能从 GitHub 恢复。未提交文件、stash、未推送分支、忽略文件、
  Git LFS 对象和子模块都需单独检查。
- 对每个新增有状态工具，先决定配置和持久数据位置，再开始长期使用。
- 系统重装前：检查配置差异和项目 Git 状态，停止数据库写入，备份持久数据，实际恢复抽查。

## 已知缺口

- SSH 已迁移并保留原件；Codex 将在最后退出后备份。
- 当前仓库还没有接管所有个人配置，不能直接将全部 `~/.config` 加入 Git。
- macOS 登录、钥匙串、应用沙盒与系统授权不由 chezmoi 完整恢复。
- iTerm2 的 AppSupport 条目目前只链接到本机 Library，不代表其数据已备份。
- SSH 迁移已应用到当前 Home；其他数据未迁移，Git 未提交或推送。

参考：[chezmoi 脚本](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)、
[声明式安装软件](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/)。
