# 可重建的 Mac 开发环境

用 [chezmoi](https://www.chezmoi.io/) 保存可公开的配置，用 Homebrew 和 mise 重建工具。
长期数据放在外部磁盘 Vault，源码提交到对应的 GitHub 仓库；系统盘可以重新安装。

## 恢复

先挂载 Vault，再从可信副本取得这个仓库。在仓库目录执行：

```sh
bash scripts/restore-macos.sh
```

默认恢复配置、基础命令行工具和 mise 工具。需要同时安装完整应用清单时：

```sh
bash scripts/restore-macos.sh --apps
```

脚本会安装软件、应用配置并恢复已登记的链接（目前包括 SSH），但不会搬迁数据、推送代码或抹盘。
首次恢复前，需确保外盘已有 `/Volumes/Vault/mac-state/ssh`。
已有系统上运行前，先用 `chezmoi diff` 检查本机配置与仓库的差异。

## 平时检查

```sh
bash scripts/check-rebuild.sh
```

这是只读检查，不是抹盘许可，也不能验证完整备份或 GitHub 上的最新状态。

详细约定、外盘目录安排和重装步骤见 [恢复手册](docs/rebuild-macos.md)。
