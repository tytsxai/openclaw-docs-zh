# OpenClaw API 配置指南

> 配置日期：2026-02-09  
> 适用版本：OpenClaw 2026.2.3+

---

## 概述

OpenClaw 支持多种 AI 模型提供商，通过统一的配置格式进行集成。

**配置文件位置**：`~/.openclaw/openclaw.json`

---

## 当前环境实配（2026-02-09）

以下是当前本机复检通过的配置（脱敏版）：

```json
{
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "apiKey": "nvapi-...",
        "api": "openai-completions",
        "models": [
          {
            "id": "moonshotai/kimi-k2.5",
            "name": "Kimi K2.5",
            "reasoning": false,
            "contextWindow": 200000,
            "maxTokens": 8192
          }
        ]
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
      "botToken": "<BOT_TOKEN>",
      "allowFrom": ["5585975222"],
      "dmPolicy": "allowlist",
      "groupPolicy": "allowlist",
      "streamMode": "off"
    }
  }
}
```

> 说明：这里使用 `openai` 作为 provider 名称，`baseUrl` 指向 NVIDIA OpenAI 兼容接口，是当前 OpenClaw 最直接稳定的配置方式。

---

## 支持的模型提供商

| 提供商 | API 类型 | 推荐度 | 特点 |
|--------|----------|--------|------|
| **Anthropic** | anthropic-messages | ⭐⭐⭐ | Claude 系列，长上下文，提示注入防护强 |
| **OpenAI** | openai-completions | ⭐⭐⭐ | GPT 系列，Codex 支持 |
| **NVIDIA** | openai-completions | ⭐⭐⭐ | 多模型聚合，Kimi, Qwen 等 |
| **Google** | google-generative-ai | ⭐⭐ | Gemini 系列 |
| **OpenRouter** | openai-completions | ⭐⭐ | 多提供商聚合，统一接口 |
| **GitHub Copilot** | github-copilot | ⭐⭐ | Copilot 免费额度 |
| **AWS Bedrock** | bedrock-converse-stream | ⭐ | 企业级，按需付费 |

---

## 配置结构说明

```json
{
  "env": {
    "PROVIDER_API_KEY": "your-api-key"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "provider-id": {
        "baseUrl": "https://api.provider.com/v1",
        "apiKey": "your-api-key",
        "api": "api-type",
        "models": [...]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "provider-id/model-id"
      }
    }
  }
}
```

**字段说明**：

| 字段 | 必填 | 说明 |
|------|------|------|
| `env.PROVIDER_API_KEY` | 可选 | 环境变量方式存储 API Key |
| `models.providers.*.baseUrl` | 是 | API 基础 URL |
| `models.providers.*.apiKey` | 是 | API 密钥 |
| `models.providers.*.api` | 是 | API 协议类型 |
| `models.providers.*.models` | 是 | 模型列表 |
| `agents.defaults.model.primary` | 是 | 默认使用的模型 |

---

## 提供商配置示例

### 1. Anthropic (Claude) ⭐️ 推荐

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-api03-..."
  },
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.anthropic.com",
        "apiKey": "sk-ant-api03-...",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "claude-opus-4-5",
            "name": "Claude Opus 4.5",
            "contextWindow": 200000,
            "maxTokens": 8192,
            "cost": {
              "input": 15,
              "output": 75,
              "cacheRead": 1.5,
              "cacheWrite": 3.75
            }
          },
          {
            "id": "claude-sonnet-4-5",
            "name": "Claude Sonnet 4.5",
            "contextWindow": 200000,
            "maxTokens": 8192,
            "cost": {
              "input": 3,
              "output": 15,
              "cacheRead": 0.3,
              "cacheWrite": 0.75
            }
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-5"
      }
    }
  }
}
```

**获取 API Key**：https://console.anthropic.com/

---

### 2. OpenAI (GPT/Codex)

```json
{
  "env": {
    "OPENAI_API_KEY": "sk-..."
  },
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "apiKey": "sk-...",
        "api": "openai-completions",
        "models": [
          {
            "id": "gpt-5.2",
            "name": "GPT-5.2",
            "contextWindow": 128000,
            "maxTokens": 16384
          },
          {
            "id": "gpt-5.2-mini",
            "name": "GPT-5.2 Mini",
            "contextWindow": 128000,
            "maxTokens": 16384
          },
          {
            "id": "codex-5.2",
            "name": "Codex 5.2",
            "contextWindow": 128000,
            "maxTokens": 16384
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/gpt-5.2"
      }
    }
  }
}
```

**获取 API Key**：https://platform.openai.com/api-keys

---

### 3. NVIDIA (Kimi, Qwen, Llama) ⭐️ 当前使用

```json
{
  "env": {
    "NVIDIA_API_KEY": "nvapi-..."
  },
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "apiKey": "nvapi-...",
        "api": "openai-completions",
        "models": [
          {
            "id": "moonshotai/kimi-k2.5",
            "name": "Kimi K2.5",
            "reasoning": false,
            "contextWindow": 200000,
            "maxTokens": 8192,
            "cost": {
              "input": 2,
              "output": 8,
              "cacheRead": 1,
              "cacheWrite": 2
            }
          },
          {
            "id": "qwen/qwen2.5-72b",
            "name": "Qwen 2.5 72B",
            "contextWindow": 32768,
            "maxTokens": 4096
          },
          {
            "id": "meta/llama-3.3-70b",
            "name": "Llama 3.3 70B",
            "contextWindow": 128000,
            "maxTokens": 4096
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/moonshotai/kimi-k2.5"
      },
      "models": {
        "openai/moonshotai/kimi-k2.5": {
          "alias": "kimi"
        }
      }
    }
  }
}
```

**获取 API Key**：https://build.nvidia.com/

---

### 4. Google (Gemini)

```json
{
  "env": {
    "GOOGLE_API_KEY": "AIza..."
  },
  "models": {
    "providers": {
      "google": {
        "baseUrl": "https://generativelanguage.googleapis.com",
        "apiKey": "AIza...",
        "api": "google-generative-ai",
        "models": [
          {
            "id": "gemini-2.0-flash",
            "name": "Gemini 2.0 Flash",
            "contextWindow": 1000000,
            "maxTokens": 8192
          },
          {
            "id": "gemini-2.0-pro",
            "name": "Gemini 2.0 Pro",
            "contextWindow": 2000000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-2.0-flash"
      }
    }
  }
}
```

**获取 API Key**：https://aistudio.google.com/app/apikey

---

### 5. OpenRouter

```json
{
  "env": {
    "OPENROUTER_API_KEY": "sk-or-v1-..."
  },
  "models": {
    "providers": {
      "openrouter": {
        "baseUrl": "https://openrouter.ai/api/v1",
        "apiKey": "sk-or-v1-...",
        "api": "openai-completions",
        "models": [
          {
            "id": "anthropic/claude-opus-4",
            "name": "Claude Opus 4 (via OpenRouter)"
          },
          {
            "id": "openai/gpt-4o",
            "name": "GPT-4o (via OpenRouter)"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/anthropic/claude-opus-4"
      }
    }
  }
}
```

**获取 API Key**：https://openrouter.ai/keys

---

### 6. GitHub Copilot

```json
{
  "models": {
    "providers": {
      "github-copilot": {
        "api": "github-copilot",
        "auth": "oauth",
        "models": [
          {
            "id": "claude-sonnet-4-5",
            "name": "Claude Sonnet 4.5 (Copilot)"
          },
          {
            "id": "gpt-4o",
            "name": "GPT-4o (Copilot)"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "github-copilot/claude-sonnet-4-5"
      }
    }
  }
}
```

**注意**：需运行 `openclaw login` 进行 OAuth 授权

---

## 多模型配置

配置多个提供商，让 OpenClaw 自动选择：

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-...",
    "NVIDIA_API_KEY": "nvapi-...",
    "OPENAI_API_KEY": "sk-..."
  },
  "models": {
    "mode": "merge",
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.anthropic.com",
        "apiKey": "sk-ant-...",
        "api": "anthropic-messages",
        "models": [{"id": "claude-opus-4-5", "name": "Claude Opus"}]
      },
      "nvidia": {
        "baseUrl": "https://integrate.api.nvidia.com/v1",
        "apiKey": "nvapi-...",
        "api": "openai-completions",
        "models": [{"id": "moonshotai/kimi-k2.5", "name": "Kimi K2.5"}]
      }
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

---

## 模型别名配置

为常用模型设置简短别名：

```json
{
  "agents": {
    "defaults": {
      "models": {
        "anthropic/claude-opus-4-5": {
          "alias": "opus"
        },
        "anthropic/claude-sonnet-4-5": {
          "alias": "sonnet"
        },
        "nvidia/moonshotai/kimi-k2.5": {
          "alias": "kimi"
        },
        "openai/gpt-5.2": {
          "alias": "gpt"
        }
      }
    }
  }
}
```

**使用别名**：
```bash
openclaw agent --message "Hello" --model opus
openclaw agent --message "Hello" --model kimi
```

---

## 成本配置

为模型配置成本信息，用于用量追踪：

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "models": [{
          "id": "claude-opus-4-5",
          "cost": {
            "input": 15,
            "output": 75,
            "cacheRead": 1.5,
            "cacheWrite": 3.75
          }
        }]
      }
    }
  }
}
```

**成本单位**：美元 / 1M tokens

---

## 配置验证

修改配置后，运行以下命令验证：

```bash
# 验证配置语法
openclaw doctor

# 测试模型连接
openclaw agent --agent main --session-id healthcheck-api --message "test" --thinking low

# 查看当前配置
openclaw config get agents.defaults.model.primary

# 查看可用模型
openclaw models list
```

---

## 故障排查

### API Key 无效

```bash
# 测试 API 连接
curl -X POST "https://api.provider.com/v1/chat/completions" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "model-id", "messages": [{"role": "user", "content": "test"}]}'
```

### 模型未找到

```bash
# 检查模型 ID 是否正确
openclaw models list

# 检查配置文件语法
cat ~/.openclaw/openclaw.json | python -m json.tool
```

### 配置未生效

```bash
# 重启 Gateway
openclaw gateway restart
```

---

## 参考链接

- [OpenClaw 模型配置文档](https://docs.openclaw.ai/concepts/models)
- [模型故障转移](https://docs.openclaw.ai/concepts/model-failover)
- [Anthropic API](https://docs.anthropic.com/)
- [OpenAI API](https://platform.openai.com/docs)
- [NVIDIA API](https://build.nvidia.com/)

---

*文档版本：v1.0*  
*最后更新：2026-02-06*
