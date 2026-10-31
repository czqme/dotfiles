#!/usr/bin/env bash
# Read-only: no fetch, install, copying, linking, or credential contents.
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
warnings=0
warn() { printf 'CHECK: %s\n' "$*"; warnings=$((warnings + 1)); }

if /sbin/mount | /usr/bin/grep -Fq ' on /Volumes/Vault ('; then
  printf 'OK: Vault is mounted (device identity and backups not verified).\n'
else
  warn 'Vault is not mounted.'
fi

if [ -L "$HOME/.ssh" ] && [ "$(readlink "$HOME/.ssh")" = /Volumes/Vault/mac-state/ssh ] && [ -d "$HOME/.ssh" ]; then
  printf 'OK: SSH points to the configured Vault directory.\n'
else
  warn 'SSH is not linked to the available Vault SSH directory.'
fi

if command -v git >/dev/null; then
  changes="$(git -C "$repo_dir" status --porcelain --untracked-files=normal)"
  if [ -n "$changes" ]; then
    warn 'Dotfiles have uncommitted changes:'
    printf '%s\n' "$changes"
  else
    printf 'OK: dotfiles working tree is clean.\n'
  fi
  if counts="$(git -C "$repo_dir" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)"; then
    printf 'Local tracking comparison (ahead, behind; no network verification): %s\n' "$counts"
    if [ "$(printf '%s' "$counts" | awk '{print $1}')" != 0 ]; then
      warn 'Dotfiles contain commits ahead of the locally recorded upstream.'
    fi
  else
    warn 'Dotfiles branch has no usable upstream tracking reference.'
  fi
else
  warn 'git is not available.'
fi

for tool in chezmoi brew mise git gh; do
  if command -v "$tool" >/dev/null; then
    printf 'OK: %s is available.\n' "$tool"
  else
    warn "$tool is missing from PATH."
  fi
done

printf '\nSelected persistent-data locations (existence is not proof of a backup):\n'
for relative in .codex .claude .claude.json .buzz .superset .paseo .pi .cc-switch .local/share/opencode; do
  target="$HOME/$relative"
  if [ -L "$target" ]; then
    if [ -e "$target" ]; then
      printf 'LINK: ~/%s -> %s (verify storage and backup separately)\n' "$relative" "$(readlink "$target")"
    else
      warn "~/$relative is a broken link."
    fi
  elif [ -e "$target" ]; then
    warn "~/$relative is a local path; confirm external persistence or a current backup."
  fi
done

printf '\nManual checks: chezmoi diff; project branches/stashes/untracked files; private project data; credentials; app data; backup restore test.\n'
printf 'This check does not establish that the Mac can safely be erased.\n'
if [ "$warnings" -gt 0 ]; then exit 1; fi
