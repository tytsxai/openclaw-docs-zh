# OpenClaw 部署文档集

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![OpenClaw Version](https://img.shields.io/badge/OpenClaw-2026.2.3%2B-green)](https://github.com/openclaw/openclaw)

> 一套完整的 OpenClaw 本地部署、配置和维护文档  
> 适用版本：OpenClaw 2026.2.3+  
> 最后更新：2026-02-06

---

## 关于本项目

本项目是 OpenClaw 部署文档的开源版本，旨在帮助用户快速部署和配置 OpenClaw。

- **开源协议**: MIT License
- **贡献**: 欢迎通过 Pull Request 或 Issue 贡献
- **问题反馈**: [GitHub Issues](https://github.com/openclaw/openclaw/issues)

---

## 📚 文档导航

### 快速开始
| 文档 | 说明 | 阅读顺序 |
|------|------|----------|
| [OpenClaw-部署指南.md](./OpenClaw-部署指南.md) | 完整部署教程 | ⭐ 第 1 步 |
| [OpenClaw-命令速查.md](./OpenClaw-命令速查.md) | 常用命令参考 | 日常查阅 |

### 配置指南
| 文档 | 说明 |
|------|------|
| [OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md) | AI 模型配置详解（Anthropic, OpenAI, NVIDIA 等） |

### 运维管理
| 文档 | 说明 |
|------|------|
| [OpenClaw-健康状态报告.md](./OpenClaw-健康状态报告.md) | 当前部署状态和健康检查 |
| [OpenClaw-故障排查指南.md](./OpenClaw-故障排查指南.md) | 问题诊断和解决方案 |
| [OpenClaw-备份与恢复指南.md](./OpenClaw-备份与恢复指南.md) | 数据备份和灾难恢复 |

### 安全
| 文档 | 说明 |
|------|------|
| [OpenClaw-安全最佳实践.md](./OpenClaw-安全最佳实践.md) | 安全配置和防护建议 |

---

## 🚀 快速开始

### 1. 首次部署

```bash
# 阅读部署指南
cat "OpenClaw-部署指南.md"

# 或使用一键安装脚本
chmod +x install-openclaw.sh
./install-openclaw.sh
```

### 2. 配置 AI 模型

```bash
# 查看 API 配置指南
cat "OpenClaw-API配置指南.md"

# 编辑配置
openclaw config edit
```

### 3. 日常运维

```bash
# 健康检查
openclaw doctor

# 查看状态
openclaw status

# 命令速查参考
# cat "OpenClaw-命令速查.md"
```

---

## 📁 文件说明

| 文件 | 类型 | 说明 |
|------|------|------|
| `README.md` | 文档 | 本文档，导航入口 |
| `OpenClaw-部署指南.md` | 文档 | 完整部署教程 |
| `OpenClaw-命令速查.md` | 文档 | 命令参考卡片 |
| `OpenClaw-API配置指南.md` | 文档 | 模型配置说明 |
| `OpenClaw-健康状态报告.md` | 报告 | 当前部署状态 |
| `OpenClaw-故障排查指南.md` | 文档 | 故障诊断手册 |
| `OpenClaw-备份与恢复指南.md` | 文档 | 数据保护指南 |
| `OpenClaw-安全最佳实践.md` | 文档 | 安全配置指南 |
| `install-openclaw.sh` | 脚本 | 一键安装脚本 |

---

## 🔧 常用操作

### 健康检查

```bash
# 快速检查
ps aux | grep openclaw
openclaw status
openclaw doctor

# 详细报告参考
# cat "OpenClaw-健康状态报告.md"
```

### 故障排查

```bash
# 遇到问题时的排查流程：
# 1. 查看日志
tail -n 50 ~/.openclaw/logs/gateway.err.log

# 2. 运行诊断
openclaw doctor

# 3. 参考故障排查指南
# cat "OpenClaw-故障排查指南.md"
```

### 备份配置

```bash
# 快速备份
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak.$(date +%Y%m%d)

# 完整备份流程参考
# cat "OpenClaw-备份与恢复指南.md"
```

---

## 📖 学习路径

### 新用户
1. [部署指南](./OpenClaw-部署指南.md) - 按步骤完成首次部署
2. [API 配置指南](./OpenClaw-API配置指南.md) - 配置 AI 模型
3. [命令速查](./OpenClaw-命令速查.md) - 熟悉常用命令

### 运维人员
1. [健康状态报告](./OpenClaw-健康状态报告.md) - 了解当前状态
2. [故障排查指南](./OpenClaw-故障排查指南.md) - 掌握诊断方法
3. [备份与恢复](./OpenClaw-备份与恢复指南.md) - 建立备份策略

### 安全管理员
1. [安全最佳实践](./OpenClaw-安全最佳实践.md) - 安全配置
2. [部署指南 - 安全章节](./OpenClaw-部署指南.md#安全加固) - 实施加固

---

## 🔗 外部资源

- **官方文档**: https://docs.openclaw.ai
- **GitHub**: https://github.com/openclaw/openclaw
- **Discord 社区**: https://discord.gg/clawd
- **官方网站**: https://openclaw.ai

---

## 📝 文档更新

### 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.2 | 2026-02-06 | 新增 API 配置、安全、备份、故障排查文档 |
| v1.1 | 2026-02-06 | 新增健康状态检查章节，修正配置文件路径 |
| v1.0 | 2026-02-05 | 初始版本，基础部署指南 |

### 维护说明

- 本文档集与 OpenClaw 版本同步更新
- 发现错误请在 GitHub 提交 Issue
- 建议定期查看官方文档获取最新信息

### 贡献代码

欢迎贡献！请阅读 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解贡献指南。

---

## ⚠️ 重要提示

1. **安全风险**: OpenClaw 连接真实消息渠道，所有入站消息被视为不可信输入
2. **备份重要**: 定期备份配置文件，避免数据丢失
3. **权限控制**: 确保 `~/.openclaw` 目录权限为 700
4. **API Key 安全**: 使用环境变量存储敏感信息

---

## 📞 获取帮助

遇到问题？

1. 查看 [故障排查指南](./OpenClaw-故障排查指南.md)
2. 运行 `openclaw doctor` 进行自动诊断
3. 查阅 [官方文档](https://docs.openclaw.ai)
4. 加入 [Discord 社区](https://discord.gg/clawd) 寻求帮助

---

*文档版本：v1.2*  
*最后更新：2026-02-06*
