#!/bin/bash
# OpenClaw 一键安装脚本
# 创建于：2026-02-05

set -e

echo "🦞 OpenClaw 安装脚本"
echo "===================="
echo ""

# 检查 Node.js
echo "🔍 检查环境..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    echo "请先安装 Node.js ≥22: https://nodejs.org"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo "⚠️  Node.js 版本过低 (当前: $(node --version))"
    echo "建议升级至 Node.js ≥22"
fi

echo "✅ Node.js: $(node --version)"

# 检查 npm/pnpm
if command -v pnpm &> /dev/null; then
    INSTALLER="pnpm add -g openclaw@latest"
    echo "✅ 使用 pnpm 安装"
elif command -v npm &> /dev/null; then
    INSTALLER="npm install -g openclaw@latest"
    echo "✅ 使用 npm 安装"
else
    echo "❌ 未找到 npm 或 pnpm"
    exit 1
fi

# 安装 OpenClaw
echo ""
echo "📦 正在安装 OpenClaw..."
echo "   这可能需要几分钟..."
echo ""
$INSTALLER

# 验证
echo ""
echo "✅ 验证安装..."
if command -v openclaw &> /dev/null; then
    VERSION=$(openclaw --version 2>/dev/null | head -1)
    echo "   OpenClaw $VERSION 安装成功！"
else
    echo "⚠️  安装完成但命令未找到"
    echo "   可能需要重启终端或检查 PATH"
fi

# 创建配置目录并设置权限
echo ""
echo "🔒 设置权限..."
mkdir -p ~/.openclaw
chmod 700 ~/.openclaw
echo "   配置目录: ~/.openclaw"

# 完成
echo ""
echo "🎉 安装完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "快速开始："
echo ""
echo "  1️⃣  配置 AI 模型"
echo "     $ openclaw configure"
echo ""
echo "  2️⃣  启动 Gateway"
echo "     $ openclaw gateway --verbose"
echo ""
echo "  3️⃣  查看状态"
echo "     $ openclaw status"
echo ""
echo "  4️⃣  测试 AI"
echo "     $ openclaw agent --message 'Hello'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 文档：/Users/xiaomo/Desktop/OpenClaw-部署指南.md"
echo "🔗 官网：https://openclaw.ai"
echo "📖 文档：https://docs.openclaw.ai"
echo ""
