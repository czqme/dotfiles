#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: bash scripts/restore-macos.sh [--apps]\n'
  printf 'Installs tools and applies chezmoi configuration. Mount /Volumes/Vault first.\n'
}

profile=core
case "${1:-}" in
  '') ;;
  --apps) profile=all; shift ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac
if [ "$#" -ne 0 ]; then usage >&2; exit 2; fi
if [ "$(uname -s)" != Darwin ]; then
  printf 'This recovery entry point is for macOS only.\n' >&2
  exit 1
fi
if ! /sbin/mount | /usr/bin/grep -Fq ' on /Volumes/Vault ('; then
  printf 'Mount the external Vault volume before restoring this environment.\n' >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash "$repo_dir/install.sh"

# Homebrew may have been installed by chezmoi in a child shell.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null
brew bundle install --no-upgrade --file="$repo_dir/dot_config/brew/Brewfile-core"
if [ "$profile" = all ]; then
  brew bundle install --no-upgrade --file="$repo_dir/dot_config/brew/Brewfile"
fi
(cd "$HOME" && mise install)
printf '\nTools and chezmoi configuration restored.\n'
printf 'Complete logins, macOS permissions, and per-tool data links using docs/rebuild-macos.md.\n'
