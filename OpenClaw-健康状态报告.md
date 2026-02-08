# OpenClaw 部署健康状态报告（最新）

> 复检时间：2026-02-09 02:59（CST）  
> 本机版本：OpenClaw `2026.2.6-3`（`b23d886`）  
> 参考上游：`https://github.com/openclaw/openclaw`  
> 维护仓库：`/Users/xiaomo/openclaw`

---

## 总体结论

**状态：✅ 可运行 / ⚠️ 模型时延波动较大**

| 检查项 | 结果 | 备注 |
|---|---|---|
| Gateway 状态 | ✅ 正常 | `openclaw gateway status` 显示 `running`、`RPC probe: ok` |
| Telegram 探活 | ✅ 正常 | `openclaw channels status --probe --json` 返回 `probe.ok=true` |
| Telegram 发消息 | ✅ 成功 | `messageId=100`, `chatId=5585975222` |
| 全局 CLI 链接 | ✅ 已修正 | `/opt/homebrew/lib/node_modules/openclaw -> /Users/xiaomo/openclaw` |
| `session-id` 路由 | ✅ 正常 | 显式 `--session-id` 已按请求会话执行 |
| Kimi K2.5 调用 | ⚠️ 波动 | `timeout=120s` 易超时；`180s~240s` 可稳定拿到结果 |

---

## 核心验证记录

### 1) Gateway / Telegram

执行：

```bash
openclaw gateway status
openclaw channels status --probe --json
```

结果：网关运行正常，Telegram 机器人 `@openclawclaw888bot` 轮询与探活正常。

### 2) Telegram 发送测试

执行：

```bash
openclaw message send --channel telegram --target 5585975222 --message "OpenClaw 健康检查..." --json
```

结果：

- `payload.ok = true`
- `payload.messageId = 100`
- `payload.chatId = 5585975222`

### 3) Agent 运行与超时阈值

关键样例：

- 成功：`verify-sessionid-1770574573`，`durationMs=49083`
- 超时：`postfix-retry-*`（`--timeout 120`），`aborted=true`
- 成功：`k25-final-t180-1770576789`，`durationMs=73227`
- 成功：`final-k25-1770576511`，`durationMs=107183`（`--timeout 240`）

结论：

- 会话路由问题已修复。
- 当前主要风险为 `moonshotai/kimi-k2.5` 响应时间波动，不是通道或网关故障。

---

## 当前生效配置（按你的参数）

- Base URL：`https://integrate.api.nvidia.com/v1`
- API：`openai-completions`
- 模型：`moonshotai/kimi-k2.5`
- Telegram Bot：`@openclawclaw888bot`
- Telegram allowlist：`5585975222`
- Telegram streamMode：`off`

---

## 建议

1. 继续使用 `kimi-k2.5` 时，建议命令级超时设置为 **>=180 秒**（建议 240 秒）。
2. 每次升级后执行一次烟囱测试：

```bash
openclaw agent --agent main --session-id smoke-$(date +%s) --message '请仅回复：UPGRADE_OK' --thinking low --timeout 180 --json
```

3. 若短时延优先，可临时改用 `moonshotai/kimi-k2-instruct`。

---

*报告生成时间：2026-02-09 02:59（CST）*
