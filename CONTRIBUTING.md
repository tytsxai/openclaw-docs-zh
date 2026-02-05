# 贡献指南 🎉

感谢您有兴趣为 OpenClaw 文档项目贡献力量！

> **每一条贡献都让文档变得更好** — 无论是修正一个错别字，还是添加一个完整的章节。

---

## 目录

- [🤝 欢迎贡献者](#欢迎贡献者)
- [🐛 报告问题](#报告问题)
- [📝 改进文档](#改进文档)
- [💡 分享经验](#分享经验)
- [📜 文档规范](#文档规范)
- [🔄 提交流程](#提交流程)
- [❓ 常见问题](#常见问题)

---

## 🤝 欢迎贡献者

我们欢迎所有形式的贡献，无论大小：

| 贡献类型 | 示例 | 难度 |
|----------|------|------|
| 🐛 错误修复 | 修正拼写、修复命令错误 | ⭐ |
| 📝 内容补充 | 添加遗漏的步骤或说明 | ⭐⭐ |
| 🔧 结构优化 | 重新组织章节结构 | ⭐⭐ |
| 🌍 翻译 | 添加多语言支持 | ⭐⭐⭐ |
| ✨ 新文档 | 添加全新的使用指南 | ⭐⭐⭐ |

**不需要是专家才能贡献** — 你的视角和经验对其他用户同样有价值！

---

## 🐛 报告问题

### 发现问题？

请在 [GitHub Issues](https://github.com/openclaw/openclaw/issues) 中：

1. **搜索是否已有类似问题** — 可能已经有人报告过了
2. **创建新问题** — 使用以下模板：

```markdown
## 问题描述
[简要描述问题]

## 环境信息
- 操作系统：[如 macOS Sonoma 14.0]
- OpenClaw 版本：[如 2026.2.3]
- 文档版本：[如 v1.2]

## 重现步骤
1. [步骤 1]
2. [步骤 2]
3. [...]

## 预期行为
[你期望发生什么]

## 实际行为
[实际发生了什么]

## 截图或日志
[如果有的话，添加截图或错误日志]
```

### 问题反馈渠道

| 类型 | 渠道 |
|------|------|
| 📝 文档错误 | GitHub Issues |
| 💬 使用问题 | [Discord 社区](https://discord.gg/clawd) |
| 💡 功能建议 | GitHub Discussions |
| 🔒 安全问题 | 发送邮件至 security@openclaw.ai |

---

## 📝 改进文档

### 快速开始

```bash
# 1. Fork 本仓库
# 点击 GitHub 页面上的 "Fork" 按钮

# 2. 克隆到本地
git clone https://github.com/YOUR_USERNAME/openclaw-docs.git
cd openclaw-docs

# 3. 创建分支
git checkout -b improve-documentation

# 4. 修改文档
# 使用你喜欢的编辑器

# 5. 提交更改
git commit -m "docs: 修正拼写错误"

# 6. 推送到你的仓库
git push origin improve-documentation

# 7. 创建 Pull Request
# 访问 GitHub 页面，点击 "New Pull Request"
```

### 推荐的提交信息格式

```
docs: 文档类型 - 简短描述

可选的详细说明

Types:
- docs: 文档改进
- fix: 错误修复
- feat: 新增内容
- refactor: 重构结构
- style: 格式调整
```

### 好的提交示例

```
docs: 修正 install 命令中的拼写错误

将 "npm install -g opencalw" 修正为 "npm install -g openclaw"
```

```
docs: 补充 NVIDIA API Key 获取步骤

在 "获取 API Key" 部分添加了：
- 登录 NVIDIA Build 平台的具体步骤
- 截图展示 Key 的位置
```

```
feat: 新增 Docker 部署章节

添加了使用 Docker 部署 OpenClaw 的完整指南，
包括 docker-compose 配置示例。
```

---

## 💡 分享经验

### 分享你的使用案例

1. 访问 [GitHub Discussions](https://github.com/openclaw/openclaw/discussions)
2. 选择 "Show & Tell" 分类
3. 分享你的：
   - 部署经验
   - 最佳实践
   - 自动化脚本
   - 实用技巧

### 编写教程

如果你写了关于 OpenClaw 的博客或教程，欢迎：

- 在 README 中添加链接
- 提交 PR 更新外部资源列表
- 在 Discussions 中分享

---

## 📜 文档规范

### 文件命名

| 类型 | 示例 |
|------|------|
| 部署指南 | `OpenClaw-部署指南.md` |
| 配置指南 | `OpenClaw-API配置指南.md` |
| 故障排除 | `OpenClaw-故障排查指南.md` |

### Markdown 格式

```markdown
# 一级标题（每文件只有一个）

## 二级标题

### 三级标题

#### 四级标题（尽量避免）

**粗体** 用于强调
`行内代码` 用于命令和参数
```

### 代码块规范

```bash
# 命令示例
npm install -g openclaw@latest

# 配置示例
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

### 中文排版

- 使用中文标点符号（，。：；？！""）
- 中英文之间添加空格
- 数字和单位之间不加空格（如：8GB）

### 文档元信息

每个文档顶部应包含：

```markdown
# 文档标题

> 简要描述
> 适用版本/日期

---

## 内容...
```

### 底部签名

```markdown
---

*文档版本：vx.x*
*最后更新：YYYY-MM-DD*
*贡献者：@username*
```

---

## 🔄 提交流程

### Pull Request 审查

1. 提交 PR 后，维护者会进行审查
2. 可能会提出修改建议
3. 通过后合并到主分支

### 审查标准

- ✅ 内容准确、符合 OpenClaw 实际情况
- ✅ 格式规范、易于阅读
- ✅ 没有泄露敏感信息
- ✅ 适合目标用户群体

### 合并后

- 你的贡献会记录在 [CHANGELOG.md](./CHANGELOG.md)
- 感谢你的付出！🎉

---

## ❓ 常见问题

### Q: 我不太懂 Git，能贡献吗？

**A:** 当然可以！最简单的贡献方式是：
1. 在 GitHub 网页上编辑文件
2. 点击文件名旁的 "Edit" 按钮
3. 编辑后点击 "Commit changes"

### Q: 我的英文不好，可以贡献吗？

**A:** 当然可以！本项目主要使用中文，而且我们鼓励用你最熟悉的语言。

### Q: 贡献会被接受吗？

**A:** 我们会认真考虑每一条贡献。如果有不合适的地方，维护者会说明原因并给出建议。

### Q: 如何获得更多帮助？

**A:** 
- Discord 社区：https://discord.gg/clawd
- GitHub Discussions：https://github.com/openclaw/openclaw/discussions

---

## 🎯 贡献者权益

### 致谢

所有贡献者都会在以下位置被感谢：

- [README.md](./README.md) - 贡献者列表
- [CHANGELOG.md](./CHANGELOG.md) - 版本历史
- GitHub 贡献图谱

### Star 支持

给项目一个 Star 是最简单但非常有价值的支持！

---

## 📞 联系方式

| 渠道 | 链接 |
|------|------|
| 💬 Discord | https://discord.gg/clawd |
| 🐙 GitHub | https://github.com/openclaw/openclaw |
| 📧 邮件 | contact@openclaw.ai |

---

**感谢您的贡献！** 🎉

你的每一条贡献都在帮助其他用户更好地使用 OpenClaw。
