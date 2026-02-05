# OpenClaw 命令速查表

> 最后更新：2026-02-06

---

## 安装与升级

```bash
npm install -g openclaw@latest        # 安装/升级到最新版
npm install -g openclaw@2026.2.3      # 安装指定版本
npm uninstall -g openclaw             # 卸载

openclaw --version                    # 查看版本
openclaw update                       # 更新到最新版
openclaw update --channel beta        # 切换到 beta 频道
openclaw update --channel dev         # 切换到 dev 频道
```

---

## 初始配置

```bash
openclaw onboard                      # 运行设置向导
openclaw onboard --install-daemon     # 向导 + 安装守护进程
openclaw configure                    # 修改配置（交互式）
openclaw config get                   # 查看所有配置
openclaw config get models.providers  # 查看特定配置项
openclaw config set key value         # 设置配置项
openclaw config edit                  # 直接编辑配置文件
```

---

## Gateway 管理

```bash
# 启动
openclaw gateway --verbose            # 前台启动（调试）
openclaw gateway --port 18789         # 指定端口
openclaw gateway start                # 后台启动
openclaw gateway restart              # 重启

# 停止
openclaw gateway stop                 # 停止服务
openclaw gateway kill                 # 强制停止
pkill -9 -f openclaw-gateway          # 强制终止进程

# 状态检查
openclaw gateway probe                # 测试连通性
openclaw gateway logs                 # 查看日志
lsof -i :18789                        # 检查端口占用
```

---

## 状态检查

```bash
openclaw status                       # 基本状态
openclaw status --all                 # 完整状态
openclaw status --deep                # 深度检查（含性能数据）

openclaw logs                         # 查看日志
openclaw logs --follow                # 实时跟踪日志
openclaw logs --channel telegram      # 查看特定频道日志

openclaw doctor                       # 运行诊断
openclaw doctor --fix                 # 自动修复问题

openclaw health                       # 健康检查
```

---

## AI 交互

```bash
# 基础对话
openclaw agent --message "Hello"      # 发送消息
openclaw agent --message "Help" --thinking high
openclaw agent --message "Code review" --model kimi

# 使用特定会话
openclaw agent --agent main --message "test"
openclaw agent --session-id <id> --message "continue"

# 文件操作
openclaw agent --message "Read @file.txt"
openclaw agent --message "Edit @script.js"
```

---

## 会话管理

```bash
openclaw sessions list                # 列出所有会话
openclaw sessions list --format json  # JSON 格式输出
openclaw sessions show <id>           # 查看会话详情
openclaw sessions history <id>        # 查看会话历史

openclaw session reset                # 重置当前会话
openclaw session compact              # 压缩会话上下文
openclaw session save <name>          # 保存会话
openclaw session load <name>          # 加载会话
```

---

## 频道管理

```bash
# 配置频道
openclaw channels configure           # 配置所有频道
openclaw channels configure telegram  # 配置特定频道

# 登录/连接
openclaw channels login telegram      # Telegram 登录
openclaw channels login whatsapp      # WhatsApp 扫码登录
openclaw channels connect discord     # 连接 Discord

# 状态检查
openclaw channels status              # 查看所有频道状态
openclaw channels status telegram     # 查看特定频道

# 断开连接
openclaw channels disconnect telegram # 断开特定频道
openclaw channels disconnect --all    # 断开所有频道

# 配对管理
openclaw pairing list                 # 查看待处理配对
openclaw pairing approve <code>       # 批准配对
openclaw pairing reject <code>        # 拒绝配对
```

---

## 模型管理

```bash
openclaw models list                  # 列出所有模型
openclaw models list --providers      # 按提供商分组
openclaw models test <model-id>       # 测试模型连接
openclaw models info <model-id>       # 查看模型详情
```

---

## Skills 管理

```bash
openclaw skills list                  # 列出可用 skills
openclaw skills install <name>        # 安装 skill
openclaw skills uninstall <name>      # 卸载 skill
openclaw skills update                # 更新所有 skills
openclaw skills info <name>           # 查看 skill 详情
```

---

## 安全与审计

```bash
# 安全审计
openclaw security audit               # 运行安全审计
openclaw security audit --deep        # 深度审计
openclaw security audit --fix         # 自动修复问题

# 权限管理
chmod 700 ~/.openclaw                 # 修复目录权限
chmod 600 ~/.openclaw/openclaw.json   # 修复文件权限

# 配对管理
openclaw pairing approve <channel> <code>   # 批准配对
openclaw pairing deny <channel> <code>      # 拒绝配对
```

---

## 健康检查

```bash
# 快速检查
ps aux | grep openclaw                # 检查进程
lsof -i :18789                        # 检查端口
curl http://127.0.0.1:18789/          # 测试 HTTP

# API 测试
curl -X POST "https://api.provider.com/v1/chat/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "model-id", "messages": [{"role": "user", "content": "test"}]}'

# 完整测试
openclaw agent --agent main --message "test" --thinking low
```

---

## 备份与恢复

```bash
# 备份配置
mkdir -p ~/.openclaw/backups
cp ~/.openclaw/openclaw.json ~/.openclaw/backups/openclaw.json.$(date +%Y%m%d)

# 备份完整数据
tar -czf ~/openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/

# 恢复配置
cp ~/.openclaw/backups/openclaw.json.20260205 ~/.openclaw/openclaw.json

# 查看备份
ls -lt ~/.openclaw/backups/
```

---

## 日志管理

```bash
# 查看日志
tail ~/.openclaw/logs/gateway.log
tail ~/.openclaw/logs/gateway.err.log

# 实时日志
tail -f ~/.openclaw/logs/gateway.log

# 搜索日志
grep "ERROR" ~/.openclaw/logs/gateway.log
grep -i "warning" ~/.openclaw/logs/*.log

# 日志轮转
ls -lh ~/.openclaw/logs/
rm ~/.openclaw/logs/gateway.log.*  # 清理旧日志
```

---

## 访问地址

| 服务 | 地址 |
|------|------|
| Dashboard | http://127.0.0.1:18789/ |
| Canvas | http://127.0.0.1:18789/__openclaw__/canvas/ |
| WebSocket | ws://127.0.0.1:18789 |
| 配置目录 | `~/.openclaw/` |
| 主配置 | `~/.openclaw/openclaw.json` |
| 日志目录 | `~/.openclaw/logs/` |

---

## 快捷别名（添加到 ~/.zshrc 或 ~/.bashrc）

```bash
# OpenClaw 快捷命令
alias oc='openclaw'
alias ocs='openclaw status'
alias ocl='openclaw logs --follow'
alias ocd='openclaw doctor'
alias ocg='openclaw gateway'
alias oca='openclaw agent'
alias occ='openclaw config edit'

# 快速测试
alias oct='openclaw agent --agent main --message "test" --thinking low'

# 快速重启
alias ocr='openclaw gateway restart && sleep 2 && openclaw status'
```

---

## 更多文档

- [OpenClaw-部署指南.md](./OpenClaw-部署指南.md) - 完整部署说明
- [OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md) - 模型配置详解
- [OpenClaw-故障排查指南.md](./OpenClaw-故障排查指南.md) - 问题排查
- [OpenClaw-安全最佳实践.md](./OpenClaw-安全最佳实践.md) - 安全配置
- [OpenClaw-备份与恢复指南.md](./OpenClaw-备份与恢复指南.md) - 数据保护
- [OpenClaw-健康状态报告.md](./OpenClaw-健康状态报告.md) - 状态检查

---

*最后更新: 2026-02-06*
