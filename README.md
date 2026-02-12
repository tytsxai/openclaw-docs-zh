# OpenClaw 本地部署与长期维护说明

更新时间：2026-02-11 11:42（CST）

## 1) 当前状态（已完成）

- 本地网关：运行正常（`openclaw gateway status` 与 `openclaw channels status --probe` 通过）
- Telegram 机器人：`@openclawclaw888bot` 正常轮询并可探活
- Kimi K2.5：可用但延迟波动，建议 `openclaw agent --timeout >=180`
- 当前 CLI 版本：`2026.2.6-3`
- 本地维护仓库：`/Users/xiaomo/openclaw`（已修正全局链接）
- 个人 GitHub 仓库（origin）：`https://github.com/tytsxai/openclaw-personal`
- 上游仓库（upstream）：`https://github.com/openclaw/openclaw`

## 2) 已做定制（满足“精简命令面 + 可维护”）

### 代码层（已推送）

- 统一命令过滤：`commands.include` / `commands.exclude`
  - 现在同时作用于：
    - 原生命令注册
    - 文本命令匹配
    - `/help` 与 `/commands` 展示
    - 插件命令（此前缺失，现已补齐）
- 已推送提交：
  - `99820bb46` `feat(commands): apply include/exclude filters to plugin command surfaces`
  - `86cfcf50c` `docs(commands): clarify include/exclude behavior for plugin commands`

### 运行配置层（当前生效）

- 禁用高风险/非必要命令：`bash/config/debug/restart`
- 关闭原生技能命令：`commands.nativeSkills=false`
- 精简原生命令白名单：
  - `help, commands, status, context, whoami, stop, reset, new, think, verbose, model`
- 禁用额外插件命令来源：
  - `plugins.entries.device-pair.enabled=false`
  - `plugins.entries.phone-control.enabled=false`
  - `plugins.entries.talk-voice.enabled=false`

## 3) 当前 Telegram 菜单命令

当前 `getMyCommands` 仅保留：

- `/help`
- `/commands`
- `/status`
- `/context`
- `/whoami`
- `/stop`
- `/reset`
- `/new`
- `/think`
- `/verbose`
- `/model`

## 4) 日常检查（建议每次改动后执行）

```bash
openclaw --version
openclaw gateway status
openclaw channels status --probe
curl -s "https://api.telegram.org/bot<TOKEN>/getMyCommands"
```

## 5) 与上游同步（长期维护主流程）

在仓库目录执行：

```bash
cd /Users/xiaomo/Desktop/OpenClaw-部署文档/openclaw
git fetch upstream
git checkout main
git rebase upstream/main
pnpm install --frozen-lockfile
pnpm build
pnpm check
git push origin main
```

然后部署到本机：

```bash
cd /Users/xiaomo/Desktop/OpenClaw-部署文档/openclaw
npm i -g . --force
pkill -9 -f openclaw-gateway || true
nohup openclaw gateway run --bind loopback --port 18789 --force > /tmp/openclaw-gateway.log 2>&1 &
openclaw channels status --probe
```

## 6) 一键脚本

- 上游同步脚本：`sync-upstream.sh`
- 执行方式：

```bash
# 默认：同步 openclaw/main + 安装依赖 + build/check + push
bash ./sync-upstream.sh

# 指定仓库路径/分支
bash ./sync-upstream.sh --repo ./openclaw --branch main

# 仅同步代码（跳过安装与校验）
bash ./sync-upstream.sh --skip-install --skip-verify
```

## 7) 文档索引（本目录）

- 文档导航（新增）：`OpenClaw-文档导航.md`
- 部署与运维：`OpenClaw-部署指南.md`
- 健康体检：`OpenClaw-健康状态报告.md`
- API 配置：`OpenClaw-API配置指南.md`
- 故障排查：`OpenClaw-故障排查指南.md`
- 安全建议：`OpenClaw-安全最佳实践.md`
- 完整修复方案：`OpenClaw-完整修复方案-2026-02-09.md`

## 8) 文档质量检查（新增）

本仓库已内置文档质检脚本与 CI 工作流。

```bash
# 全量检查（默认）
bash scripts/docs-check.sh --all

# 仅检查本次改动（提交前推荐）
bash scripts/docs-check.sh --changed

# 一键安装 pre-commit 钩子（推荐）
bash scripts/install-git-hooks.sh
```

检查项包括：

- 每个 Markdown 文件必须且仅有一个一级标题（H1）
- 核心文档前 20 行必须包含 `YYYY-MM-DD` 日期
- 本地 Markdown 链接必须可访问（文件存在）

CI 工作流文件：`.github/workflows/docs-quality.yml`

Git Hook 文件：`.githooks/pre-commit`

## 9) 注意事项

- 不要在文档、仓库、日志中写入真实密钥。
- 你当前维护主仓为 `openclaw-personal`，后续只在该仓持续迭代。
- 若要放开更多命令，只需调整 `commands.include` 或启用相应插件入口。
