#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="all"

print_usage() {
  cat <<'EOF'
用法：
  bash scripts/docs-check.sh [--all|--changed|--help]

参数：
  --all       检查全部受版本控制的 Markdown 文件（默认）
  --changed   仅检查变更中的 Markdown 文件（暂存区/工作区/未跟踪）
  --help      显示帮助
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)
      MODE="all"
      ;;
    --changed)
      MODE="changed"
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "❌ 未知参数：$1"
      print_usage
      exit 1
      ;;
  esac
  shift
done

if ! command -v rg >/dev/null 2>&1; then
  echo "❌ 缺少依赖：rg（ripgrep）"
  echo "请先安装 ripgrep 后重试。"
  exit 1
fi

markdown_files=()

collect_all_markdown_files() {
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    markdown_files+=("$file")
  done < <(git -c core.quotePath=false ls-files '*.md')
}

collect_changed_markdown_files() {
  local changed_list_file
  changed_list_file="$(mktemp)"
  trap 'rm -f "$changed_list_file"' RETURN

  git -c core.quotePath=false diff --cached --name-only --diff-filter=ACMR -- '*.md' >> "$changed_list_file" || true
  git -c core.quotePath=false diff --name-only --diff-filter=ACMR -- '*.md' >> "$changed_list_file" || true
  git -c core.quotePath=false ls-files --others --exclude-standard -- '*.md' >> "$changed_list_file" || true

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ -f "$file" ] || continue
    markdown_files+=("$file")
  done < <(LC_ALL=C sort -u "$changed_list_file")
}

if [ "$MODE" = "changed" ]; then
  collect_changed_markdown_files
else
  collect_all_markdown_files
fi

if [ "${#markdown_files[@]}" -eq 0 ]; then
  if [ "$MODE" = "changed" ]; then
    echo "ℹ️ 未发现变更中的 Markdown 文件，跳过检查。"
  else
    echo "⚠️ 未找到任何受版本控制的 Markdown 文件。"
  fi
  exit 0
fi

failures=0

record_failure() {
  local message="$1"
  echo "❌ ${message}"
  failures=$((failures + 1))
}

echo "==> 检查一级标题（H1）"
for file in "${markdown_files[@]}"; do
  case "$file" in
    ".github/ISSUE_TEMPLATE.md"|".github/PULL_REQUEST_TEMPLATE.md")
      continue
      ;;
  esac

  h1_count="$(awk '
    BEGIN { in_code = 0; count = 0 }
    /^```/ { in_code = !in_code; next }
    !in_code && /^# / { count++ }
    END { print count }
  ' "$file")"
  if [ "$h1_count" -ne 1 ]; then
    record_failure "${file}: 一级标题数量应为 1，当前为 ${h1_count}"
  fi

  first_non_empty_line="$(awk '
    BEGIN { in_code = 0 }
    /^```/ { in_code = !in_code; next }
    !in_code && NF { print; exit }
  ' "$file")"
  if [[ ! "$first_non_empty_line" =~ ^#\  ]]; then
    record_failure "${file}: 首个非空行应为一级标题"
  fi
done

echo "==> 检查核心文档日期字段"
core_docs=(
  "README.md"
  "OpenClaw-文档导航.md"
  "OpenClaw-部署指南.md"
  "OpenClaw-API配置指南.md"
  "OpenClaw-命令速查.md"
  "OpenClaw-健康状态报告.md"
  "OpenClaw-故障排查指南.md"
  "OpenClaw-安全最佳实践.md"
  "OpenClaw-备份与恢复指南.md"
)

is_core_doc() {
  local candidate="$1"
  local core_doc
  for core_doc in "${core_docs[@]}"; do
    if [ "$candidate" = "$core_doc" ]; then
      return 0
    fi
  done

  return 1
}

date_check_targets=()
if [ "$MODE" = "changed" ]; then
  for file in "${markdown_files[@]}"; do
    if is_core_doc "$file"; then
      date_check_targets+=("$file")
    fi
  done
else
  date_check_targets=("${core_docs[@]}")
fi

for file in "${date_check_targets[@]}"; do
  if [ ! -f "$file" ]; then
    continue
  fi

  if ! sed -n '1,20p' "$file" | rg -q '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    record_failure "${file}: 前 20 行缺少 YYYY-MM-DD 日期"
  fi
done

echo "==> 检查本地 Markdown 链接"
for file in "${markdown_files[@]}"; do
  case "$file" in
    ".github/ISSUE_TEMPLATE.md")
      continue
      ;;
  esac

  while IFS= read -r markdown_link; do
    link_target="$(echo "$markdown_link" | sed -E 's/^!?\[[^]]+\]\(([^)]+)\)$/\1/')"

    link_target="${link_target%%#*}"
    link_target="${link_target%% *}"
    link_target="${link_target#<}"
    link_target="${link_target%>}"

    if [ -z "$link_target" ]; then
      continue
    fi

    if [[ "$link_target" == \#* ]]; then
      continue
    fi

    case "$link_target" in
      http://*|https://*|mailto:*|tel:*)
        continue
        ;;
    esac

    if [[ "$link_target" == /* ]]; then
      resolved_path=".${link_target}"
    else
      resolved_path="$(dirname "$file")/${link_target}"
    fi

    if [ ! -e "$resolved_path" ]; then
      record_failure "${file}: 链接目标不存在 -> ${link_target}"
    fi
  done < <(
    awk '
      BEGIN { in_code = 0 }
      /^```/ { in_code = !in_code; next }
      !in_code { print }
    ' "$file" | rg -o '!?(\[[^]]+\]\([^)]+\))' || true
  )
done

if [ "$failures" -gt 0 ]; then
  echo ""
  echo "文档检查失败：共 ${failures} 项问题。"
  exit 1
fi

echo ""
echo "✅ 文档检查通过：${#markdown_files[@]} 个 Markdown 文件已验证（模式：${MODE}）。"
