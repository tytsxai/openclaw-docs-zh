# 文档更新日志

All notable changes to the OpenClaw documentation are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [v1.4] - 2026-02-11

### 新增

- **Git Hook 自动化**（`.githooks/pre-commit`）
  - `git commit` 时自动执行文档增量检查

- **Git Hook 安装脚本**（`scripts/install-git-hooks.sh`）
  - 一键设置 `core.hooksPath=.githooks`

### 改进

- `scripts/docs-check.sh` 新增 `--all` / `--changed` 参数
- `README.md` 增加增量检查与 Hook 安装说明
- `CONTRIBUTING.md` 增加 Hook 推荐流程与增量检查命令
- `OpenClaw-文档导航.md` 补充自动化维护路径

---

## [v1.3] - 2026-02-11

### 新增

- **文档导航与维护入口** (`OpenClaw-文档导航.md`)
  - 新增按场景阅读路径
  - 新增文档地图与维护流程
  - 新增质量门禁与更新标准

- **文档质量检查脚本** (`scripts/docs-check.sh`)
  - 校验 Markdown 文件 H1 规范
  - 校验核心文档日期字段
  - 校验本地 Markdown 链接可达性

- **CI 自动检查工作流** (`.github/workflows/docs-quality.yml`)
  - 对 `push` 与 `pull_request` 执行文档质检

### 改进

- `README.md` 新增文档导航入口与文档质检说明
- `CONTRIBUTING.md` 新增质量检查流程和结构同步要求
- `.github/DOCUMENTATION_TEMPLATE.md` 统一为 `最后更新` 字段
- `.github/PULL_REQUEST_TEMPLATE.md` 增加文档质检勾选项

---

## [v1.2] - 2026-02-06

### 新增

- **API 配置指南** (`OpenClaw-API配置指南.md`)
  - Anthropic Claude 配置说明
  - OpenAI GPT/Codex 配置说明
  - NVIDIA Kimi/Qwen/Llama 配置说明
  - Google Gemini 配置说明
  - OpenRouter 配置说明
  - GitHub Copilot 配置说明
  - 多模型配置和成本配置

- **安全最佳实践** (`OpenClaw-安全最佳实践.md`)
  - DM 配对策略配置
  - 群组安全设置
  - Docker 沙盒模式
  - Gateway 认证配置
  - 敏感信息保护
  - 防火墙和网络配置
  - 审计与监控

- **备份与恢复指南** (`OpenClaw-备份与恢复指南.md`)
  - 配置备份策略
  - 完整系统备份
  - 会话数据备份
  - 恢复操作指南
  - 迁移到新设备
  - 自动备份工具（restic、rclone）
  - 灾难恢复流程

- **故障排查指南** (`OpenClaw-故障排查指南.md`)
  - Gateway 相关问题排查
  - AI 模型问题排查
  - 配置问题排查
  - 频道连接问题排查
  - 安全问题排查
  - 性能问题排查
  - 紧急情况处理

### 改进

- 部署指南增加健康状态检查章节
- 修正配置文件路径（openclaw.json）
- 添加 NVIDIA + Kimi K2.5 配置示例
- 添加高级配置章节链接

---

## [v1.1] - 2026-02-06

### 新增

- **健康状态报告** (`OpenClaw-健康状态报告.md`)
  - 系统状态检查
  - 进程状态监控
  - 网络监听状态
  - AI 模型配置测试
  - Agent 功能测试
  - 日志状态分析

### 改进

- 修正配置文件路径
- 优化文档结构

---

## [v1.0] - 2026-02-05

### 新增

- **部署指南** (`OpenClaw-部署指南.md`)
  - 环境要求说明
  - 快速安装步骤
  - 安装后配置
  - 常用命令速查
  - 访问 Dashboard
  - 健康状态检查
  - 常见问题解答
  - 配置文件位置
  - 更新和卸载指南
  - 高级配置（多模型、安全加固、备份）
  - 一键安装脚本

- **命令速查** (`OpenClaw-命令速查.md`)
  - 安装与升级命令
  - 初始配置命令
  - Gateway 管理命令
  - 状态检查命令
  - AI 交互命令
  - 会话管理命令
  - 频道管理命令
  - 模型管理命令
  - Skills 管理命令
  - 安全与审计命令
  - 健康检查命令
  - 备份与恢复命令
  - 日志管理命令
  - 快捷别名

---

## 贡献者

感谢以下贡献者为本项目的付出：

| 版本 | 贡献者 |
|------|--------|
| v1.0 - v1.4 | OpenClaw Community |

---

## 如何贡献

欢迎通过以下方式贡献：

1. **提交 Pull Request**：改进文档或修复错误
2. **报告 Issue**：发现文档问题或遗漏
3. **分享经验**：在 Discussions 中分享使用案例
4. **Star 支持**：给我们 Star 支持一下！

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)

---

## 文档规范

### 文件命名

- 使用中文描述：`OpenClaw-xxx指南.md`
- 保持命名一致性

### Markdown 格式

- 使用中文标点符号
- 代码块使用语言标注
- 标题层级不超过 H3（###）
- 每行最大 120 字符

### 版本号规则

- **MAJOR**: 重大结构变化或新增主要章节
- **MINOR**: 新增内容或显著改进
- **PATCH**: 修正错误、拼写、格式

---

*最后更新：2026-02-11*
