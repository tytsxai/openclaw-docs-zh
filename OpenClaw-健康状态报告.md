# OpenClaw 部署健康状态报告（复检）

> 复检日期：2026-02-09  
> 本地版本：OpenClaw 2026.2.3（commit `eab0a07f7173`）  
> 环境：macOS 26.1 / Node.js v25.5.0 / pnpm 10.23.0

---

## 总体结论

**状态：✅ 可用（生产可运行）**

| 维度 | 结果 | 备注 |
|------|------|------|
| Gateway 服务 | ✅ 正常 | LaunchAgent 运行中（PID 44245） |
| Telegram 频道 | ✅ 正常 | 轮询模式运行，`@openclawclaw888bot` 探活成功 |
| 模型调用（OpenClaw 内部） | ✅ 正常 | `moonshotai/kimi-k2.5` 返回 `MODEL_AGENT_OK` |
| Telegram 发信测试 | ✅ 正常 | 发送到 `5585975222` 成功（messageId `90` / `91`） |
| 配置有效性 | ✅ 已修复 | 移除无效 `commands.include`，修正流式配置 |
| 上游一致性 | ⚠️ 需关注 | 本地分支落后 `origin/main` 253 commits |

---

## 本次复检范围

1. 对照官方仓库 `https://github.com/openclaw/openclaw` 检查本地代码同步状态
2. 核对 `~/.openclaw/openclaw.json` 的模型与 Telegram 配置
3. 执行 `gateway/status/channels/doctor` 健康检查
4. 执行模型推理与 Telegram 实发测试
5. 记录修复项与后续建议

---

## 关键配置核对（脱敏）

当前生效配置位于 `~/.openclaw/openclaw.json`：

```json
{
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "api": "openai-completions",
        "models": [{
          "id": "moonshotai/kimi-k2.5"
        }]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/moonshotai/kimi-k2.5"
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": ["5585975222"],
      "groupPolicy": "allowlist",
      "streamMode": "off"
    }
  }
}
```

### 本次修复项

- ✅ 删除无效配置项：`commands.include`（会导致 `config reload skipped (invalid config)`）
- ✅ 将 `channels.telegram.streamMode` 从 `partial` 调整为 `off`（避免外部频道分片输出）

---

## 健康检查明细

### 1) Gateway 服务状态

```bash
openclaw gateway status
```

核心结果：

- `Runtime: running (pid 44245, state active)`
- `RPC probe: ok`
- `Listening: 127.0.0.1:18789`
- `Config (cli/service): ~/.openclaw/openclaw.json`

### 2) Telegram 频道探活

```bash
openclaw channels status --probe --json
```

核心结果：

- `configured: true`
- `running: true`
- `mode: polling`
- `probe.ok: true`
- `probe.bot.username: openclawclaw888bot`

### 3) 综合状态

```bash
openclaw status --json
```

核心结果：

- Gateway reachable：`true`
- 默认模型：`moonshotai/kimi-k2.5`
- 安全审计：`critical=0, warn=0, info=1`

### 4) Doctor 诊断

```bash
openclaw doctor --non-interactive
```

当前仅剩 1 项非阻塞提示：

- `Gateway service entrypoint does not match the current install`
- 显示链路：`/opt/homebrew/lib/node_modules/openclaw/dist/index.js -> /Users/xiaomo/openclaw/dist/index.js`

> 说明：该提示与全局 npm 链接（符号链接）相关，不影响当前运行。

---

## 连通与功能测试结果

### 1) NVIDIA API 可达性

```bash
curl -sS --max-time 30 https://integrate.api.nvidia.com/v1/models \
  -H "Authorization: Bearer <NVIDIA_API_KEY>"
```

结果：`HTTP 200`，并能查到 `moonshotai/kimi-k2.5`。

### 2) OpenClaw 模型调用实测

```bash
openclaw agent --agent main --session-id healthcheck-20260209-1 \
  --message "请仅回复：MODEL_AGENT_OK" --thinking low --timeout 70 --json
```

结果（摘要）：

- `status: ok`
- `summary: completed`
- 回复内容：`MODEL_AGENT_OK`
- 模型：`moonshotai/kimi-k2.5`
- 耗时：约 `20531ms`

### 3) Telegram 出站消息测试

```bash
openclaw message send --channel telegram --target 5585975222 \
  --message "OpenClaw 健康检查测试消息" --json
```

结果：

- `payload.ok: true`
- `chatId: 5585975222`
- `messageId: 90`（后续复测 `91`）

---

## 与原生仓库一致性检查

仓库：`/Users/xiaomo/openclaw`

- 当前分支：`main`
- 本地 commit：`eab0a07f7173`
- 上游最新：`origin/main @ 7f7d49aef...`
- Ahead/Behind：`0 / 253`
- 本地未提交改动：`15` 个文件

建议：如需完全贴近原生项目，请先备份本地改动再执行 rebase/merge。

---

## 后续建议

1. **版本同步**：在确认本地 15 个改动用途后，再同步到 `origin/main`。
2. **定期复检**：每周执行一次 `openclaw doctor --non-interactive` 与 `openclaw channels status --probe`。
3. **配置变更后重启**：每次改动 `~/.openclaw/openclaw.json` 后执行 `openclaw gateway restart`。
4. **安全审计**：补充执行 `openclaw security audit --deep` 并归档结果。

---

*报告生成时间：2026-02-09 01:50*  
*检查工具：openclaw gateway/status/channels/doctor、openclaw agent、openclaw message、curl、git*
