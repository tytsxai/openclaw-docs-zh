# AGENTS.md

最后更新：2026-03-20

## 仓库目标

用最少文档覆盖最多核心场景，信息收敛到单一主文档。

## 目录结构

```
.
├── AGENTS.md                          # 本文件：仓库规则
├── README.md                          # 总览与快速入口
├── STATS.md                           # 文档字数统计
├── OpenClaw-部署运维一体化指南.md      # 执行层唯一主文档
├── OpenClaw-设备迁移指南.md            # 设备迁移专项指南
├── CHANGELOG.md                       # 版本演进记录
├── openclaw-migrate.sh                # 旧机器备份脚本
├── openclaw-restore.sh                # 新机器恢复脚本
├── openclaw-health-check.sh           # 健康检查脚本
└── .github/
    ├── DOCUMENTATION_TEMPLATE.md
    ├── ISSUE_TEMPLATE.md
    └── PULL_REQUEST_TEMPLATE.md
```

## 文件职责

| 文件 | 职责 |
|------|------|
| `OpenClaw-部署运维一体化指南.md` | 部署、配置、运维、排障、安全备份——执行层主文档 |
| `OpenClaw-设备迁移指南.md` | 设备迁移专项：清单、打包、传输、恢复、验收 |
| `README.md` | 导航入口，不重复主文档内容 |
| `STATS.md` | 文件字数统计，含一键刷新命令 |
| `CHANGELOG.md` | 文档变更记录 |

## 维护规则

1. 任何命令变更，先改主文档，再同步 README 和 CHANGELOG。
2. 同一信息出现在多个文件时，收敛到主文档，其他文件用链接引用。
3. 新增文档前先判断能否并入主文档。
4. 结构变更（新增/删除/重命名文件）必须同步更新本文件。
5. 官方文档 https://docs.clawdbot.org.cn 与本地冲突时，以官方为准。
