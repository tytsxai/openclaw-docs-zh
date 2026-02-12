#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d ".git" ]; then
  echo "❌ 当前目录不是 Git 仓库：$ROOT_DIR"
  exit 1
fi

git config core.hooksPath .githooks

echo "✅ 已启用仓库级 Git Hooks（core.hooksPath=.githooks）"
echo "   pre-commit 将自动执行：bash scripts/docs-check.sh --changed"
