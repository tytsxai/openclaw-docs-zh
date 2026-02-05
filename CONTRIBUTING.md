# 贡献指南

感谢您有兴趣为 OpenClaw 文档项目贡献力量！

## 如何贡献

### 报告问题
- 在 [GitHub Issues](https://github.com/openclaw/openclaw/issues) 中搜索是否已有类似问题
- 创建新问题时，请提供：
  - 清晰的问题描述
  - 重现步骤
  - 预期行为与实际行为
  - 环境信息（操作系统、OpenClaw 版本等）

### 改进文档
- 拼写修正、语法改进
- 添加缺失的操作步骤
- 补充更多使用示例
- 改进现有说明的清晰度

### 提交 Pull Request

1. **Fork 本仓库**
2. **创建分支**
   ```bash
   git checkout -b improve-documentation
   ```
3. **修改文档**
4. **提交更改**
   ```bash
   git commit -m "docs: 改进部署指南的安装步骤说明"
   ```
5. **推送并创建 PR**
   ```bash
   git push origin improve-documentation
   ```

## 文档规范

### 文件命名
- 使用中文描述：`OpenClaw-xxx指南.md`
- 保持命名一致性

### Markdown 格式
- 使用中文标点符号
- 代码块使用语言标注
- 标题层级不超过 H3（###）
- 每行最大 120 字符

### 示例格式
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

## 联系方式

- GitHub Discussions: https://github.com/openclaw/openclaw/discussions
- Discord 社区: https://discord.gg/clawd
