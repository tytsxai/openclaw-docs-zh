# OpenClaw 安全最佳实践

> 文档版本：v1.0  
> 最后更新：2026-02-06

---

## 安全警告 ⚠️

OpenClaw 连接到真实的消息渠道，**所有入站消息都被视为不可信输入**。请务必阅读以下安全指南。

---

## 1. 默认安全设置

### 1.1 DM（私信）配对策略

默认情况下，OpenClaw 使用 **pairing** 模式处理私信：

```json
{
  "channels": {
    "telegram": {
      "dm": {
        "policy": "pairing"
      }
    },
    "whatsapp": {
      "dmPolicy": "pairing"
    },
    "discord": {
      "dm": {
        "policy": "pairing"
      }
    }
  }
}
```

**配对模式说明**：
- 未知发送者收到配对码，消息不会被处理
- 必须使用 `openclaw pairing approve <channel> <code>` 批准
- 批准后发送者被添加到本地白名单

---

### 1.2 安全策略选项

| 策略 | 说明 | 风险等级 |
|------|------|----------|
| `pairing` | 需要配对码验证（默认） | 🟢 低 |
| `allowlist` | 只允许白名单用户 | 🟢 低 |
| `open` | 接受所有消息（危险） | 🔴 高 |
| `disabled` | 禁用私信 | 🟢 低 |

---

## 2. 安全配置建议

### 2.1 生产环境最小安全配置

```json
{
  "channels": {
    "telegram": {
      "botToken": "YOUR_TOKEN",
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      },
      "groups": {
        "requireMention": true,
        "allowFrom": []
      }
    },
    "whatsapp": {
      "dmPolicy": "pairing",
      "allowFrom": []
    },
    "discord": {
      "token": "YOUR_TOKEN",
      "dm": {
        "policy": "pairing",
        "allowFrom": []
      },
      "guilds": []
    }
  },
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main"
      }
    }
  }
}
```

---

### 2.2 群组安全设置

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "requireMention": true,
        "allowFrom": ["group-id-1", "group-id-2"]
      }
    }
  }
}
```

**群组安全建议**：
- ✅ 启用 `requireMention`：只在被 @ 时响应
- ✅ 使用 `allowFrom` 限制允许的群组
- ✅ 不在公开大群组中部署
- ❌ 避免使用 `"*"` 允许所有群组

---

### 2.3 沙盒模式（强烈推荐）

为非主会话启用 Docker 沙盒：

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "allowlist": [
          "bash",
          "process",
          "read",
          "write",
          "edit",
          "sessions_list",
          "sessions_history",
          "sessions_send"
        ],
        "denylist": [
          "browser",
          "canvas",
          "nodes",
          "cron",
          "discord",
          "gateway"
        ]
      }
    }
  }
}
```

**沙盒模式说明**：
- `non-main`：主会话（直接对话）无限制，群组/频道会话在沙盒中运行
- `all`：所有会话都在沙盒中运行
- `off`：禁用沙盒（不推荐用于生产）

---

## 3. 认证与授权

### 3.1 Gateway 认证

```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "your-secure-random-token"
    }
  }
}
```

**生成安全 Token**：
```bash
# 生成 256-bit 随机 token
openssl rand -hex 32

# 设置 token
openclaw config set gateway.auth.token "$(openssl rand -hex 32)"
```

---

### 3.2 Tailscale 安全访问

```json
{
  "gateway": {
    "bind": "loopback",
    "tailscale": {
      "mode": "serve",
      "resetOnExit": true
    },
    "auth": {
      "mode": "token",
      "allowTailscale": true
    }
  }
}
```

**安全说明**：
- `serve`：仅 Tailnet 内部可访问
- `funnel`：公共访问（需要密码认证）
- `bind` 必须为 `loopback` 才能使用 Tailscale

---

## 4. 敏感信息保护

### 4.1 API Key 管理

**不推荐**（直接写入配置文件）：
```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "sk-ant-..."
      }
    }
  }
}
```

**推荐**（使用环境变量）：
```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-..."
  },
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      }
    }
  }
}
```

**更安全**（仅使用 env）：
```bash
# 写入 ~/.profile 或 ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-..."
```

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      }
    }
  }
}
```

---

### 4.2 密钥定期轮换 (Key Rotation)

**重要安全提示**：
如果在调试过程中，API Key 或 Bot Token 曾以明文形式出现在：
1. 终端输出
2. 日志文件
3. Agent 历史对话记录（`~/.openclaw/agents/*/sessions/`）

**必须立即轮换（Revoke & Regenerate）该密钥**。

轮换后，请仅在 `~/.openclaw/openclaw.json` 或环境变量中更新新密钥，并确保执行 `openclaw gateway restart` 使其生效。

---

### 4.3 配置文件权限

```bash
# 设置正确的文件权限
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
chmod -R 600 ~/.openclaw/credentials/

# 验证权限
ls -la ~/.openclaw/
# 预期输出：
# drwx------  openclaw
# -rw-------  openclaw.json
```

---

### 4.3 从日志中移除敏感信息

```bash
# 清理历史日志中的 API Key
sed -i 's/sk-ant-[a-zA-Z0-9]*/REDACTED/g' ~/.openclaw/logs/*.log
sed -i 's/nvapi-[a-zA-Z0-9]*/REDACTED/g' ~/.openclaw/logs/*.log
```

---

## 5. 网络安全

### 5.1 防火墙配置

```bash
# 仅允许本地访问 Gateway 端口
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add openclaw

# Linux (ufw)
sudo ufw deny 18789/tcp
sudo ufw allow from 127.0.0.1 to any port 18789

# Linux (iptables)
sudo iptables -A INPUT -p tcp --dport 18789 -s 127.0.0.1 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 18789 -j DROP
```

---

### 5.2 SSH 隧道访问（远程访问）

```bash
# 本地端口转发
ssh -L 18789:localhost:18789 user@remote-host

# 然后访问本地端口
openclaw status --probe http://127.0.0.1:18789
```

---

## 6. 命令权限控制

### 6.1 限制可用工具

```json
{
  "agents": {
    "defaults": {
      "tools": {
        "allowlist": [
          "bash",
          "read",
          "write",
          "edit"
        ],
        "denylist": [
          "browser",
          "canvas",
          "nodes",
          "cron",
          "discord",
          "slack",
          "gateway"
        ]
      }
    }
  }
}
```

---

### 6.2 提升权限控制

```json
{
  "agents": {
    "defaults": {
      "elevated": {
        "enabled": false
      }
    }
  }
}
```

**说明**：
- `enabled: false`：禁用 `/elevated` 命令
- `enabled: true`：允许特定会话临时提升权限

---

## 7. 审计与监控

### 7.1 启用审计日志

```json
{
  "logging": {
    "level": "info",
    "audit": {
      "enabled": true,
      "events": ["command", "tool", "message"]
    }
  }
}
```

---

### 7.2 定期安全审计

```bash
# 运行安全审计
openclaw security audit

# 查看详细报告
openclaw security audit --deep

# 自动修复问题
openclaw security audit --fix
```

---

## 8. 安全更新

### 8.1 保持更新

```bash
# 检查更新
openclaw update --check

# 更新到最新稳定版
openclaw update --channel stable

# 更新后运行诊断
openclaw doctor
```

---

### 8.2 漏洞响应

如果发现安全漏洞：

1. **立即隔离**
```bash
openclaw gateway stop
openclaw channels disconnect --all
```

2. **收集信息**
```bash
openclaw doctor > security-incident-$(date +%Y%m%d).txt
```

3. **报告问题**
- GitHub Security: https://github.com/openclaw/openclaw/security
- 邮件：security@openclaw.ai

---

## 9. 安全清单

部署前检查：

- [ ] DM 策略设置为 `pairing` 或 `allowlist`
- [ ] 群组已限制 `allowFrom`
- [ ] Gateway 认证已启用
- [ ] 配置文件权限为 600
- [ ] 目录权限为 700
- [ ] API Key 使用环境变量
- [ ] 沙盒模式已启用
- [ ] 敏感工具已禁用
- [ ] 审计日志已启用
- [ ] 运行了 `openclaw security audit`

---

## 10. 参考资源

- [OpenClaw 安全指南](https://docs.openclaw.ai/gateway/security)
- [DM 配对文档](https://docs.openclaw.ai/gateway/pairing)
- [Docker 沙盒](https://docs.openclaw.ai/install/docker)
- [Tailscale 集成](https://docs.openclaw.ai/gateway/tailscale)

---

*文档版本：v1.0*  
*最后更新：2026-02-06*
