#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${OPENCLAW_REPO_DIR:-${SCRIPT_DIR}/openclaw}"
TARGET_BRANCH="${OPENCLAW_TARGET_BRANCH:-main}"

usage() {
  cat <<'EOF'
Usage: sync-upstream.sh [--repo <path>] [--branch <name>] [--skip-install] [--skip-verify]

Options:
  --repo <path>       OpenClaw 源码仓库路径（默认：脚本同级目录下 openclaw）
  --branch <name>     目标分支（默认：main）
  --skip-install      跳过依赖安装
  --skip-verify       跳过 build/check 验证
  -h, --help          显示帮助

Env:
  OPENCLAW_REPO_DIR      覆盖仓库路径
  OPENCLAW_TARGET_BRANCH 覆盖目标分支
EOF
}

SKIP_INSTALL=0
SKIP_VERIFY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_DIR="$2"
      shift 2
      ;;
    --branch)
      TARGET_BRANCH="$2"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=1
      shift
      ;;
    --skip-verify)
      SKIP_VERIFY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

for cmd in git pnpm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Invalid repo dir: $REPO_DIR (missing .git)" >&2
  exit 1
fi

cd "$REPO_DIR"

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "Missing upstream remote in $REPO_DIR" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean in $REPO_DIR; commit/stash first." >&2
  exit 1
fi

echo "[1/6] Fetch upstream"
git fetch upstream

echo "[2/6] Checkout ${TARGET_BRANCH}"
git checkout "$TARGET_BRANCH"

echo "[3/6] Rebase onto upstream/${TARGET_BRANCH}"
git rebase "upstream/${TARGET_BRANCH}"

if [[ "$SKIP_INSTALL" -eq 0 ]]; then
  echo "[4/6] Install deps"
  pnpm install --frozen-lockfile
else
  echo "[4/6] Install deps (skipped)"
fi

if [[ "$SKIP_VERIFY" -eq 0 ]]; then
  echo "[5/6] Validate"
  pnpm build
  pnpm check
else
  echo "[5/6] Validate (skipped)"
fi

echo "[6/6] Push to origin/${TARGET_BRANCH}"
git push origin "$TARGET_BRANCH"

echo "Done. Current HEAD: $(git rev-parse --short HEAD)"
