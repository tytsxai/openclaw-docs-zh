# OpenClaw 本地部署指南

> 部署日期：2026-02-05  
> 环境：macOS ARM64 / Node.js v25.5.0 / Docker 29.2.1

---

## 1. 环境要求

| 组件 | 版本 | 检查命令 |
|------|------|----------|
| Node.js | ≥22 | `node --version` |
| npm/pnpm | 任意 | `npm --version` / `pnpm --version` |
| Docker | 可选 | `docker --version` |

---

## 2. 快速安装（推荐）

### 步骤 1：全局安装

```bash
npm install -g openclaw@latest
```

> 耗时：约 4 分钟（安装 696 个包）

### 步骤 2：验证安装

```bash
openclaw --version
# 输出：2026.2.2-3
```

### 步骤 3：运行配置向导

```bash
openclaw onboard --install-daemon
```

**向导交互步骤：**

| 步骤 | 选择 | 说明 |
|------|------|------|
| 1 | ✅ Yes | 确认安全风险警告 |
| 2 | QuickStart | 选择快速配置模式 |
| 3 | Skip for now | 跳过模型提供商配置（可后续配置） |
| 4 | Keep current | 使用默认模型 (anthropic/claude-opus-4-5) |
| 5 | Skip for now | 跳过频道配置（可后续配置） |

### 步骤 4：检查状态

```bash
openclaw status
```

---

## 3. 安装后配置

### 3.1 修复安全警告

```bash
# 修复目录权限
chmod 700 ~/.openclaw

# 运行安全审计修复
openclaw security audit --fix
```

### 3.2 配置 AI 模型

```bash
openclaw configure
# 按提示选择模型提供商并设置 API key
```

支持的提供商：
- Anthropic (Claude) ⭐️ 推荐
- OpenAI (ChatGPT/Codex)
- Google (Gemini)
- OpenRouter
- 其他...

### 3.3 启动 Gateway

```bash
# 前台启动（调试用，或**需要截图/视觉功能时**）
openclaw gateway run --verbose

# 后台启动（使用守护进程，**仅限文本/无头模式**）
openclaw gateway start
```

> **注意**：macOS 系统下，如果需要使用 **截屏 (Screenshot)** 或 **视觉分析** 功能，必须使用 `openclaw gateway run` 在前台运行。后台服务（LaunchAgent）因系统权限限制无法获取屏幕内容。

### 3.4 配置消息频道（可选）

```bash
openclaw configure
```

支持的频道：
- Telegram Bot
- WhatsApp (QR 扫码)
- Discord Bot
- Slack
- Signal
- iMessage (BlueBubbles)
- Google Chat
- Microsoft Teams
- WebChat（内置）

---

## 4. 常用命令速查

| 命令 | 功能 |
|------|------|
| `openclaw status` | 查看系统状态 |
| `openclaw status --all` | 查看完整状态 |
| `openclaw logs --follow` | 实时查看日志 |
| `openclaw gateway start` | 启动 Gateway |
| `openclaw gateway stop` | 停止 Gateway |
| `openclaw gateway probe` | 测试 Gateway 连通性 |
| `openclaw configure` | 修改配置 |
| `openclaw agent --message "xxx"` | 发送消息给 AI |
| `openclaw doctor` | 运行诊断 |
| `openclaw security audit` | 安全审计 |
| `openclaw update` | 更新到最新版 |

---

## 5. 访问 Dashboard

Gateway 启动后：

```
http://127.0.0.1:18789/
```

---

## 6. 健康状态检查

部署完成后，建议运行以下检查确保系统健康：

### 6.1 快速健康检查

```bash
# 1. 检查 Gateway 进程
ps aux | grep openclaw
# 预期输出：openclaw-gateway 进程在运行

# 2. 检查端口监听
lsof -i :18789
# 预期输出：显示 openclaw-gateway 监听 18789 端口

# 3. 运行诊断
openclaw doctor

# 4. 测试 AI 连接
openclaw agent --agent main --message "test" --thinking low
```

### 6.2 健康状态指标

| 检查项 | 正常状态 | 检查命令 |
|--------|----------|----------|
| Gateway 进程 | 运行中 | `ps aux \| grep openclaw` |
| WebSocket 监听 | 127.0.0.1:18789 | `lsof -i :18789` |
| AI 模型响应 | 正常返回 | `openclaw agent --message "test"` |
| 配置文件 | 无语法错误 | `openclaw doctor` |
| 目录权限 | 700 | `ls -ld ~/.openclaw` |

### 6.3 详细健康报告

详见 **[OpenClaw-健康状态报告.md](./OpenClaw-健康状态报告.md)**

当前部署状态摘要：
- ✅ Gateway 运行中 (PID 88413)
- ✅ WebSocket 监听正常
- ✅ NVIDIA API 连接正常
- ✅ Kimi K2.5 模型可用
- ⚠️ 建议修复：目录权限、OAuth 目录

---

## 7. 常见问题

### Q1: Gateway 无法启动

```bash
# 检查端口占用
lsof -i :18789

# 检查日志
openclaw logs
```

### Q2: 模型配置错误

```bash
# 重新配置
openclaw configure

# 或者编辑配置文件
vim ~/.openclaw/openclaw.json
```

**配置示例**（NVIDIA + Kimi K2.5）：
```json
{
  "env": {
    "NVIDIA_API_KEY": "nvapi-YOUR_KEY_HERE"
  },
  "models": {
    "providers": {
      "nvidia": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "apiKey": "nvapi-YOUR_KEY_HERE",
        "api": "openai-completions",
        "models": [{
          "id": "moonshotai/kimi-k2.5",
          "name": "Kimi K2.5"
        }]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "nvidia/moonshotai/kimi-k2.5"
      }
    }
  }
}
```

### Q3: 频道连接失败

```bash
# 检查频道状态
openclaw status --all

# 查看频道日志
openclaw logs --channel telegram
```

### Q4: 权限问题

```bash
# 确保配置目录权限正确
chmod 700 ~/.openclaw
```

---

## 7. 配置文件位置

| 文件 | 路径 |
|------|------|
| 主配置 | `~/.openclaw/openclaw.json` |
| 会话数据 | `~/.openclaw/agents/main/sessions/` |
| 日志 | `~/.openclaw/logs/` |
| Gateway 日志 | `~/.openclaw/logs/gateway.log` |
| 错误日志 | `~/.openclaw/logs/gateway.err.log` |
| 工作区 | `~/.openclaw/workspace/` |

---

## 8. 更新 OpenClaw

```bash
npm update -g openclaw
# 或
openclaw update
```

---

## 9. 卸载

```bash
npm uninstall -g openclaw
rm -rf ~/.openclaw
```

---

## 10. 参考链接

- 官方文档：https://docs.openclaw.ai
- GitHub：https://github.com/openclaw/openclaw
- Discord：https://discord.gg/clawd
- 官网：https://openclaw.ai

---

## 8. 高级配置

### 8.1 多模型配置

支持同时配置多个 AI 提供商：

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "anthropic": { "apiKey": "...", "models": [...] },
      "nvidia": { "apiKey": "...", "models": [...] }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-5",
        "fallback": "nvidia/moonshotai/kimi-k2.5"
      }
    }
  }
}
```

详见 **[OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md)**

### 8.2 安全加固

生产环境建议配置：

```json
{
  "channels": {
    "telegram": { "dm": { "policy": "pairing" } }
  },
  "agents": {
    "defaults": {
      "sandbox": { "mode": "non-main" }
    }
  }
}
```

详见 **[OpenClaw-安全最佳实践.md](./OpenClaw-安全最佳实践.md)**

### 8.3 备份与恢复

定期备份配置：

```bash
# 备份
mkdir -p ~/.openclaw/backups
cp ~/.openclaw/openclaw.json ~/.openclaw/backups/openclaw.json.$(date +%Y%m%d)

# 恢复
cp ~/.openclaw/backups/openclaw.json.20260205 ~/.openclaw/openclaw.json
```

详见 **[OpenClaw-备份与恢复指南.md](./OpenClaw-备份与恢复指南.md)**

### 8.4 故障排查

遇到问题时的排查流程：

```bash
# 1. 检查进程
ps aux | grep openclaw

# 2. 查看日志
tail -n 50 ~/.openclaw/logs/gateway.err.log

# 3. 运行诊断
openclaw doctor

# 4. 测试连接
openclaw gateway probe
```

详见 **[OpenClaw-故障排查指南.md](./OpenClaw-故障排查指南.md)**

---

## 附录：一键安装脚本

创建文件 `install-openclaw.sh`：

```bash
#!/bin/bash
set -e

echo "🦞 开始安装 OpenClaw..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js ≥22"
    exit 1
fi

# 安装
echo "📦 安装 OpenClaw..."
npm install -g openclaw@latest

# 验证
echo "✅ 验证安装..."
openclaw --version

# 修复权限
echo "🔒 修复权限..."
mkdir -p ~/.openclaw
chmod 700 ~/.openclaw

echo "🎉 安装完成！"
echo ""
echo "下一步："
echo "  1. 配置模型: openclaw configure"
echo "  2. 启动服务: openclaw gateway --verbose"
echo "  3. 查看状态: openclaw status"
```

使用方法：
```bash
chmod +x install-openclaw.sh
./install-openclaw.sh
```

---

*文档版本：v1.2*  
*最后更新：2026-02-06*  
*更新内容：*
- 新增健康状态检查章节
- 修正配置文件路径（openclaw.json）
- 添加 NVIDIA + Kimi K2.5 配置示例
- 添加高级配置章节（多模型、安全、备份、故障排查链接）
- 新增配套文档：API配置指南、故障排查指南、安全最佳实践、备份与恢复指南
