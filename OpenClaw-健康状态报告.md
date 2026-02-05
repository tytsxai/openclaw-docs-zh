# OpenClaw 部署健康状态报告

> 检查日期：2026-02-06  
> 部署版本：2026.2.3  
> 环境：macOS / Node.js v25.5.0 / pnpm 10.23.0

---

## 总体状态：✅ 健康运行

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Gateway 进程 | ✅ 运行中 | PID 88413, 运行 7+ 小时 |
| WebSocket 监听 | ✅ 正常 | `ws://127.0.0.1:18789` |
| AI 模型连接 | ✅ 正常 | NVIDIA API 响应 200 |
| 配置文件 | ✅ 有效 | JSON 格式正确 |
| 构建输出 | ✅ 存在 | `dist/` 目录完整 |
| Node.js 版本 | ✅ 符合要求 | v25.5.0 (≥22.12.0) |

---

## 详细检查结果

### 1. 进程状态

```bash
ps aux | grep openclaw
```

**输出：**
```
xiaomo  88413  0.0  0.2  444864992  31328  ??  S  2:03AM  0:22.17 openclaw-gateway
```

- **PID**: 88413
- **启动时间**: 2026-02-05 02:03
- **运行时长**: 7+ 小时
- **内存占用**: ~31MB

---

### 2. 网络监听状态

| 协议 | 地址 | 端口 | 状态 |
|------|------|------|------|
| WebSocket | 127.0.0.1 | 18789 | ✅ 监听 |
| WebSocket | [::1] | 18789 | ✅ 监听 |
| Canvas Host | 127.0.0.1 | 18789 | ✅ 已挂载 |

**Canvas 访问地址**：
```
http://127.0.0.1:18789/__openclaw__/canvas/
```

---

### 3. AI 模型配置

**当前配置**（`~/.openclaw/openclaw.json`）：

```json
{
  "models": {
    "providers": {
      "nvidia": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "apiKey": "nvapi-YOUR_API_KEY",
        "api": "openai-completions",
        "models": [{
          "id": "moonshotai/kimi-k2.5",
          "name": "Kimi K2.5",
          "reasoning": true,
          "contextWindow": 256000,
          "maxTokens": 4096
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

**API 测试**：
```bash
curl -X POST "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer <API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "moonshotai/kimi-k2.5",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

**响应**：HTTP 200 ✅
```json
{
  "id": "chatcmpl-af9721cdcd4ccf45",
  "model": "moonshotai/kimi-k2.5",
  "choices": [...]
}
```

---

### 4. Agent 功能测试

```bash
openclaw agent --agent main --message "Say API test OK" --thinking low
```

**输出**：
```
API test OK only
```

✅ Agent 响应正常

---

### 5. Doctor 诊断结果

```bash
openclaw doctor
```

| 检查项目 | 状态 | 详情 |
|----------|------|------|
| 状态完整性 | ⚠️ 警告 | 目录权限过于开放 |
| OAuth 目录 | ⚠️ 缺失 | `~/.openclaw/credentials` 不存在 |
| 会话记录 | ⚠️ 警告 | 1/1 会话缺少 transcript |
| 安全配置 | ✅ 正常 | 无安全警告 |
| Skills | ✅ 正常 | 8 个符合条件 |
| 插件 | ✅ 正常 | 1 个已加载 |

---

### 6. 日志状态

| 日志文件 | 大小 | 最后更新 | 状态 |
|----------|------|----------|------|
| `~/.openclaw/logs/gateway.log` | 7.5 KB | 2026-02-05 03:13 | ✅ 正常 |
| `~/.openclaw/logs/gateway.err.log` | 8.8 KB | 2026-02-05 02:06 | ⚠️ 含历史错误 |

**历史错误**（已解决）：
- `models.providers.nvidia.api: Invalid input` - 配置更新过程中的临时验证错误
- `Gateway auth is set to token, but no token is configured` - 初始配置问题，已修复

---

### 7. 文件路径汇总

| 类型 | 路径 |
|------|------|
| 主配置文件 | `~/.openclaw/openclaw.json` |
| 日志目录 | `~/.openclaw/logs/` |
| Gateway 日志 | `~/.openclaw/logs/gateway.log` |
| 错误日志 | `~/.openclaw/logs/gateway.err.log` |
| 工作区 | `~/.openclaw/workspace/` |
| 会话数据 | `~/.openclaw/agents/main/sessions/` |
| 项目源码 | `~/openclaw/` |
| 构建输出 | `~/openclaw/dist/` |

---

### 8. 已知问题

#### 8.1 非阻塞警告

**版本检测警告**（开发模式正常）：
```
Config was last written by a newer OpenClaw (2026.2.3); 
current version is 0.0.0.
```

**说明**：从源码运行时期号未写入，不影响功能。

**punycode 弃用警告**：
```
DeprecationWarning: The `punycode` module is deprecated.
```

**说明**：Node.js 内置模块弃用警告，等待上游依赖更新。

#### 8.2 建议修复

```bash
# 1. 修复目录权限
chmod 700 ~/.openclaw

# 2. 创建 OAuth 目录
mkdir -p ~/.openclaw/credentials

# 3. 运行自动修复
openclaw doctor --fix
```

---

## 健康检查命令

### 快速检查

```bash
# 检查进程
ps aux | grep openclaw

# 检查端口
lsof -i :18789

# 检查状态
openclaw status

# 运行诊断
openclaw doctor
```

### 完整检查

```bash
# 测试 API 连接
curl -s -X POST "https://integrate.api.nvidia.com/v1/chat/completions" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "moonshotai/kimi-k2.5",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 10
  }'

# 测试 Agent
openclaw agent --agent main --message "test" --thinking low

# 查看实时日志
openclaw logs --follow
```

---

## 维护建议

### 日常维护

```bash
# 每日检查
openclaw status

# 每周检查
openclaw doctor
openclaw security audit

# 查看日志
tail -f ~/.openclaw/logs/gateway.log
```

### 故障排查

```bash
# Gateway 无响应
openclaw gateway stop
openclaw gateway start --verbose

# 配置错误
openclaw doctor --fix

# 重置配置
mv ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
openclaw onboard
```

---

*报告生成时间：2026-02-06 00:20*  
*OpenClaw 版本：2026.2.3*  
*检查工具：openclaw doctor, curl, ps, lsof*
