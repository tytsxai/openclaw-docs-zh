# OpenClaw 文档导航与维护系统

> 最后更新：2026-02-11  
> 目标：5 分钟定位文档，1 条命令完成文档质检

---

## 1. 快速阅读路径

| 你的场景 | 建议阅读顺序 |
|---|---|
| 初次部署 OpenClaw | [OpenClaw-部署指南.md](./OpenClaw-部署指南.md) → [OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md) → [OpenClaw-健康状态报告.md](./OpenClaw-健康状态报告.md) |
| 日常运维与命令查询 | [OpenClaw-命令速查.md](./OpenClaw-命令速查.md) → [README.md](./README.md) |
| 故障定位与恢复 | [OpenClaw-故障排查指南.md](./OpenClaw-故障排查指南.md) → [OpenClaw-备份与恢复指南.md](./OpenClaw-备份与恢复指南.md) |
| 安全加固 | [OpenClaw-安全最佳实践.md](./OpenClaw-安全最佳实践.md) → [OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md) |
| 了解历史修复背景 | [OpenClaw-完整修复方案-2026-02-09.md](./OpenClaw-完整修复方案-2026-02-09.md) → [CHANGELOG.md](./CHANGELOG.md) |

---

## 2. 文档地图

| 文档 | 主要用途 | 目标读者 | 何时更新 |
|---|---|---|---|
| [README.md](./README.md) | 项目总览、当前状态、维护主流程 | 所有人 | 版本变更、流程变更 |
| [OpenClaw-部署指南.md](./OpenClaw-部署指南.md) | 从零部署与初始化 | 新部署用户 | 安装流程变更 |
| [OpenClaw-API配置指南.md](./OpenClaw-API配置指南.md) | 模型与 API 配置 | 使用模型接口的用户 | 提供商配置变更 |
| [OpenClaw-命令速查.md](./OpenClaw-命令速查.md) | 常用命令速览 | 日常运维 | CLI 命令变更 |
| [OpenClaw-健康状态报告.md](./OpenClaw-健康状态报告.md) | 当前环境体检结果 | 维护者 | 重大修复后复检 |
| [OpenClaw-故障排查指南.md](./OpenClaw-故障排查指南.md) | 常见问题排查 SOP | 运维与故障处理人员 | 新问题类型出现 |
| [OpenClaw-安全最佳实践.md](./OpenClaw-安全最佳实践.md) | 安全策略与防护建议 | 管理员 | 安全策略调整 |
| [OpenClaw-备份与恢复指南.md](./OpenClaw-备份与恢复指南.md) | 备份、迁移、恢复 | 运维与管理员 | 备份策略变更 |
| [CHANGELOG.md](./CHANGELOG.md) | 文档系统变更记录 | 贡献者与维护者 | 每次文档发布 |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | 贡献流程与规范 | 贡献者 | 规范与流程变更 |

---

## 3. 维护流程（标准化）

1. 选择目标文档并修改内容。
2. 同步更新文档顶部日期（`最后更新` 或 `更新时间`）。
3. 运行文档质检：`bash scripts/docs-check.sh --all`。
4. 日常提交可用增量检查：`bash scripts/docs-check.sh --changed`。
5. 可选：启用提交自动检查：`bash scripts/install-git-hooks.sh`。
6. 在 [CHANGELOG.md](./CHANGELOG.md) 追加本次变更。
7. 提交 PR，等待审查合并。

---

## 4. 自动化质量门禁

### 4.1 本地检查

```bash
# 全量检查
bash scripts/docs-check.sh --all

# 增量检查（提交前推荐）
bash scripts/docs-check.sh --changed

# 安装 pre-commit 自动检查（推荐）
bash scripts/install-git-hooks.sh
```

检查项包括：

- 每个 Markdown 文件必须且仅有一个 H1 标题。
- 核心文档前 20 行必须包含 `YYYY-MM-DD` 日期。
- 本地 Markdown 链接必须存在且可访问。

### 4.2 CI 检查

GitHub Actions 工作流：

- [`.github/workflows/docs-quality.yml`](./.github/workflows/docs-quality.yml)

在 `push` / `pull_request` 触发并执行同一套本地检查脚本，保证本地与 CI 一致。

启用 `.githooks/pre-commit` 后，`git commit` 会自动执行增量检查。

---

## 5. 新增文档最低标准

- 命名优先使用 `OpenClaw-xxx指南.md`。
- 开头 20 行包含可解析日期（`YYYY-MM-DD`）。
- 如包含本地链接，提交前确保链接可访问。
- 新增文档后同步更新 `README.md`、本导航文档与 `CHANGELOG.md`。

可复用模板：

- [`.github/DOCUMENTATION_TEMPLATE.md`](./.github/DOCUMENTATION_TEMPLATE.md)

---

## 6. 入口建议

- 面向使用者：从 [README.md](./README.md) 进入。
- 面向维护者：从 [CONTRIBUTING.md](./CONTRIBUTING.md) 与本页进入。
- 面向历史追踪：从 [CHANGELOG.md](./CHANGELOG.md) 进入。
