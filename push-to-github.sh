#!/bin/bash
set -e

echo "=== OpenClaw 文档推送脚本 ==="
echo ""

# 检查认证
if ! gh auth status &>/dev/null; then
    echo "❌ 未登录 GitHub"
    echo ""
    echo "请先完成认证："
    echo "1. 打开: https://github.com/login/device"
    echo "2. 输入代码，然后运行此脚本"
    echo ""
    echo "或使用 Token:"
    echo "   export GH_TOKEN='你的_token'"
    echo ""
    exit 1
fi

echo "✅ 已登录 GitHub"

# 创建仓库
echo ""
echo "📦 创建仓库..."
gh repo create openclaw-docs-zh --public --description "OpenClaw 部署文档集 - 完整的中文部署指南" --source=. --push

echo ""
echo "✅ 推送完成！"
echo "📍 仓库地址: $(gh repo view --json url -q .url)"
