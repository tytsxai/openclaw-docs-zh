# OpenClaw 故障排查指南

> 文档版本：v1.0  
> 最后更新：2026-02-06

---

## 快速诊断流程

遇到问题时，按以下顺序排查：

```
1. 检查进程状态 → 2. 检查日志 → 3. 检查配置 → 4. 测试连接 → 5. 重启服务
```

---

## 1. Gateway 相关问题

### 1.1 Gateway 无法启动

**症状**：`openclaw gateway start` 命令失败或立即退出

**排查步骤**：

```bash
# 1. 检查端口占用
lsof -i :18789
# 或
netstat -an | grep 18789

# 2. 检查日志
tail -n 50 ~/.openclaw/logs/gateway.err.log

# 3. 前台启动查看详细错误
openclaw gateway --verbose
```

**常见原因**：

| 原因 | 症状 | 解决方案 |
|------|------|----------|
| 端口被占用 | `EADDRINUSE` | `kill -9 <PID>` 或更换端口 |
| 配置语法错误 | JSON parse error | 检查 `~/.openclaw/openclaw.json` 语法 |
| 权限不足 | `EACCES` | `chmod 700 ~/.openclaw` |
| 内存不足 | `ENOMEM` | 关闭其他程序或增加内存 |

**修复命令**：
```bash
# 强制停止所有 OpenClaw 进程
pkill -9 -f openclaw

# 重新启动
openclaw gateway --verbose
```

---

### 1.2 Gateway 频繁崩溃

**症状**：Gateway 启动后不久自动退出

**排查**：

```bash
# 查看崩溃日志
tail -n 100 ~/.openclaw/logs/gateway.err.log

# 检查系统资源
vm_stat              # macOS
free -h              # Linux
df -h ~/.openclaw    # 磁盘空间
```

**常见原因**：
- 内存不足（建议至少 2GB 空闲内存）
- 磁盘空间不足
- 配置重载导致崩溃

---

### 1.3 Gateway 无响应

**症状**：端口监听正常但无法连接

**排查**：

```bash
# 测试端口连通性
curl -v http://127.0.0.1:18789/

# 检查进程状态
ps aux | grep openclaw

# 查看当前连接
lsof -i :18789
```

**修复**：
```bash
# 优雅重启
openclaw gateway restart

# 或强制重启
pkill -9 -f openclaw-gateway
sleep 2
openclaw gateway start
```

---

### 1.4 截图/Vision 能力失败 (macOS)

**症状**：
```
could not create image from display
```
或者 Agent 回复“无法获取屏幕截图”。

**根因**：
macOS 的权限管理机制（TCC）限制了后台进程（LaunchAgent/Daemon）获取屏幕内容的权限。即使授予了终端或 `node` 屏幕录制权限，以 Service 模式后台运行的 Gateway 也无法通过 `screencapture` 命令截图。

**解决方案**：

**方案 A（推荐）：前台运行 Gateway**
如果需要使用截图、视觉分析功能，请停止后台服务，改在**已授权屏幕录制权限**的终端中前台运行 Gateway。

```bash
# 1. 停止后台服务
openclaw gateway stop

# 2. 在当前终端前台启动
openclaw gateway run --bind loopback --port 18789 --force
```

**方案 B：仅使用文本模式**
如果不需要截图功能，可继续使用后台服务，但需接受视觉能力不可用的限制。

---

## 2. AI 模型相关问题

### 2.1 API Key 无效

**症状**：
```
HTTP 401 authentication_error: invalid api key
```

**排查**：

```bash
# 1. 测试 API Key 是否有效
curl -X POST "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "moonshotai/kimi-k2.5", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'

# 2. 检查配置文件
openclaw config get models.providers.nvidia.apiKey

# 3. 验证配置语法
cat ~/.openclaw/openclaw.json | python -m json.tool
```

**解决方案**：

```bash
# 更新 API Key
openclaw config set env.NVIDIA_API_KEY "nvapi-NEW_KEY"

# 或直接编辑配置文件
vim ~/.openclaw/openclaw.json

# 重启 Gateway
openclaw gateway restart
```

---

### 2.2 模型响应缓慢/超时

**症状**：Agent 请求长时间无响应

**排查**：

```bash
# 1. 测试网络延迟
ping api.anthropic.com

# 2. 查看当前队列
openclaw status --all | grep -A 5 queue

# 3. 检查模型配置
openclaw config get agents.defaults.model
```

**优化方案**：

```json
// 在 openclaw.json 中添加超时配置
{
  "agents": {
    "defaults": {
      "timeout": {
        "request": 120000,
        "stream": 300000
      }
    }
  }
}
```

---

### 2.3 模型输出异常

**症状**：响应内容为空、乱码或格式错误

**排查**：

```bash
# 测试基础响应
openclaw agent --message "Say 'test' only" --thinking low

# 检查模型配置
cat ~/.openclaw/openclaw.json | grep -A 10 '"models"'
```

**可能原因**：
- 模型 ID 错误
- API 类型不匹配
- 模型不支持的参数

---

## 3. 配置相关问题

### 3.1 配置语法错误

**症状**：
```
Invalid config at ~/.openclaw/openclaw.json
```

**排查**：

```bash
# 验证 JSON 语法
python -m json.tool ~/.openclaw/openclaw.json

# 或使用 jq
jq '.' ~/.openclaw/openclaw.json
```

**常见错误**：

| 错误类型 | 示例 | 修复 |
|----------|------|------|
| 缺少逗号 | `{ "a": 1 "b": 2 }` | `{ "a": 1, "b": 2 }` |
| 多余逗号 | `{ "a": 1, }` | `{ "a": 1 }` |
| 引号不匹配 | `{ 'key': 'value' }` | `{ "key": "value" }` |
| 缺少括号 | `{ "key": "value"` | `{ "key": "value" }` |

**安全修复**：
```bash
# 备份原配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak.$(date +%Y%m%d_%H%M%S)

# 重新生成配置
openclaw onboard
```

---

### 3.2 配置未生效

**症状**：修改配置后行为未改变

**排查**：

```bash
# 1. 检查配置是否被正确读取
openclaw config get

# 2. 查看配置元数据
ls -la ~/.openclaw/openclaw.json

# 3. 检查是否有多个配置文件
find ~/.openclaw -name "*.json" -type f
```

**强制重载**：
```bash
# 方法 1：发送 SIGUSR1 信号重载
kill -USR1 $(pgrep openclaw-gateway)

# 方法 2：重启 Gateway
openclaw gateway restart

# 方法 3：完全停止后启动
openclaw gateway stop
sleep 2
openclaw gateway start
```

---

## 4. 频道相关问题

### 4.1 Telegram 连接失败

**症状**：无法接收/发送 Telegram 消息

**排查**：

```bash
# 1. 检查频道状态
openclaw status --all | grep -A 10 telegram

# 2. 查看频道日志
openclaw logs --channel telegram

# 3. 测试 Bot Token
curl -s "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe"
```

**常见问题**：

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `401 Unauthorized` | Bot Token 错误 | 重新获取 Token |
| `409 Conflict` | 多个实例运行 | 停止其他实例 |
| 收不到消息 | Webhook 配置错误 | 检查 webhook URL |

---

### 4.2 Discord 连接失败

**症状**：Bot 不在线或无法响应命令

**排查**：

```bash
# 检查 Bot Token
openclaw config get channels.discord.token

# 查看日志
openclaw logs --channel discord
```

**Discord 特有配置**：
```json
{
  "channels": {
    "discord": {
      "token": "YOUR_BOT_TOKEN",
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      }
    }
  }
}
```

---

### 4.3 WhatsApp 连接失败

**症状**：WhatsApp 二维码扫描后无法连接

**排查**：

```bash
# 重新登录
openclaw channels login whatsapp

# 查看状态
openclaw channels status whatsapp

# 查看日志
openclaw logs --channel whatsapp
```

**注意**：WhatsApp 会话可能过期，需要定期重新认证。

---

## 5. 安全相关问题

### 5.1 权限警告

**症状**：
```
State directory permissions are too open
```

**修复**：
```bash
# 设置正确权限
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json

# 运行安全审计
openclaw security audit --fix
```

---

### 5.2 未授权访问

**症状**：
```
unauthorized: gateway token missing
```

**排查**：

```bash
# 检查认证配置
openclaw config get gateway.auth

# 查看当前 token
openclaw config get gateway.auth.token
```

**修复**：
```bash
# 生成新 token
openclaw config set gateway.auth.token "$(openssl rand -hex 32)"

# 重启 Gateway
openclaw gateway restart
```

---

## 6. 性能相关问题

### 6.1 CPU 使用率过高

**排查**：

```bash
# 查看 CPU 使用
top -pid $(pgrep openclaw-gateway)

# 查看详细统计
openclaw status --deep
```

**优化建议**：
- 限制并发会话数
- 禁用不必要的频道
- 调整日志级别

---

### 6.2 内存使用过高

**排查**：

```bash
# 查看内存使用
ps aux | grep openclaw

# macOS
vm_stat | head

# Linux
free -h
```

**优化配置**：
```json
{
  "agents": {
    "defaults": {
      "maxConcurrent": 2,
      "subagents": {
        "maxConcurrent": 4
      }
    }
  }
}
```

---

## 7. 日志分析

### 7.1 查看日志

```bash
# 实时查看
tail -f ~/.openclaw/logs/gateway.log

# 查看错误日志
tail -f ~/.openclaw/logs/gateway.err.log

# 搜索特定错误
grep "ERROR" ~/.openclaw/logs/gateway.log

# 按时间范围查看
awk '/2026-02-05 14:00/,/2026-02-05 15:00/' ~/.openclaw/logs/gateway.log
```

### 7.2 日志级别

```bash
# 启用详细日志
openclaw gateway --verbose

# 配置日志级别
openclaw config set logging.level "debug"
```

---

## 8. 紧急情况处理

### 8.1 完全重置

```bash
# 1. 停止服务
openclaw gateway stop
pkill -9 -f openclaw

# 2. 备份配置
cp -r ~/.openclaw ~/.openclaw.backup.$(date +%Y%m%d_%H%M%S)

# 3. 清除状态
rm -rf ~/.openclaw/agents/*/sessions/*
rm -rf ~/.openclaw/logs/*

# 4. 重新配置
openclaw onboard

# 5. 启动服务
openclaw gateway start
```

### 8.2 重新安装

```bash
# 1. 完全卸载
npm uninstall -g openclaw
pkill -9 -f openclaw
rm -rf ~/.openclaw

# 2. 重新安装
npm install -g openclaw@latest

# 3. 运行向导
openclaw onboard --install-daemon
```

---

## 9. 获取帮助

### 9.1 内置帮助

```bash
# 命令帮助
openclaw --help
openclaw gateway --help
openclaw agent --help

# 查看文档
openclaw docs
```

### 9.2 社区支持

- **GitHub Issues**: https://github.com/openclaw/openclaw/issues
- **Discord**: https://discord.gg/clawd
- **官方文档**: https://docs.openclaw.ai

### 9.3 提交 Issue

```bash
# 收集诊断信息
openclaw doctor > doctor-report.txt
openclaw status --all > status-report.txt
tar -czf openclaw-debug.tar.gz doctor-report.txt status-report.txt ~/.openclaw/logs/
```

**注意**：提交日志前请删除敏感信息（API Key、电话号码等）

---

*文档版本：v1.0*  
*最后更新：2026-02-06*
