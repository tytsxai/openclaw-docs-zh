# OpenClaw 备份与恢复指南

> 文档版本：v1.0  
> 最后更新：2026-02-06

---

## 备份策略概览

| 备份类型 | 频率 | 保留时间 | 包含内容 |
|----------|------|----------|----------|
| **配置备份** | 每次修改后 | 永久 | `openclaw.json` |
| **完整备份** | 每周 | 30天 | 配置 + 会话 + 日志 |
| **会话备份** | 每日 | 7天 | 活跃会话数据 |
| **自动备份** | 实时 | 最近10个 | 配置版本历史 |

---

## 1. 配置备份

### 1.1 手动备份配置

```bash
# 创建配置备份目录
mkdir -p ~/.openclaw/backups

# 备份主配置
cp ~/.openclaw/openclaw.json ~/.openclaw/backups/openclaw.json.$(date +%Y%m%d_%H%M%S)

# 压缩备份
tar -czf ~/.openclaw/backups/config-$(date +%Y%m%d).tar.gz \
  ~/.openclaw/openclaw.json \
  ~/.openclaw/credentials/ 2>/dev/null || true
```

### 1.2 自动备份脚本

创建 `~/.openclaw/backup.sh`：

```bash
#!/bin/bash
set -e

BACKUP_DIR="$HOME/.openclaw/backups"
DATE=$(date +%Y%m%d_%H%M%S)
KEEP_DAYS=30

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份配置文件
cp "$HOME/.openclaw/openclaw.json" "$BACKUP_DIR/openclaw.json.$DATE"

# 备份会话数据（可选）
if [ -d "$HOME/.openclaw/agents" ]; then
    tar -czf "$BACKUP_DIR/sessions-$DATE.tar.gz" -C "$HOME/.openclaw" agents/
fi

# 清理旧备份（保留30天）
find "$BACKUP_DIR" -name "*.json.*" -mtime +$KEEP_DAYS -delete
find "$BACKUP_DIR" -name "sessions-*.tar.gz" -mtime +$KEEP_DAYS -delete

echo "备份完成: $BACKUP_DIR/openclaw.json.$DATE"
```

添加到 crontab：

```bash
# 编辑 crontab
crontab -e

# 添加每日备份任务（每天凌晨3点）
0 3 * * * /bin/bash $HOME/.openclaw/backup.sh >> $HOME/.openclaw/logs/backup.log 2>&1
```

---

### 1.3 使用 git 版本控制

```bash
# 初始化 git 仓库
cd ~/.openclaw
git init
git add openclaw.json
git commit -m "Initial config"

# 每次修改后提交
git add openclaw.json
git commit -m "Update config: $(date)"

# 查看历史
git log --oneline

# 回滚到某个版本
git checkout <commit-hash> -- openclaw.json
```

---

## 2. 完整系统备份

### 2.1 备份整个 OpenClaw 目录

```bash
#!/bin/bash
# 完整备份脚本

BACKUP_DIR="$HOME/backups/openclaw"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="openclaw-full-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

# 停止服务
openclaw gateway stop 2>/dev/null || true
sleep 2

# 创建完整备份
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='logs/*.log' \
    -C "$HOME" \
    .openclaw/

echo "完整备份完成: $BACKUP_DIR/$BACKUP_FILE"
echo "备份大小: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"
```

### 2.2 排除敏感信息的备份

```bash
#!/bin/bash
# 安全备份（移除 API Key）

BACKUP_DIR="$HOME/backups/openclaw"
DATE=$(date +%Y%m%d)
TEMP_DIR=$(mktemp -d)

# 复制配置
cp ~/.openclaw/openclaw.json "$TEMP_DIR/"

# 移除敏感信息
sed -i.bak \
    -e 's/"apiKey": "[^"]*"/"apiKey": "REDACTED"/g' \
    -e 's/"token": "[^"]*"/"token": "REDACTED"/g' \
    "$TEMP_DIR/openclaw.json"

# 创建备份
tar -czf "$BACKUP_DIR/openclaw-safe-$DATE.tar.gz" -C "$TEMP_DIR" .

# 清理
rm -rf "$TEMP_DIR"

echo "安全备份完成（API Key 已移除）"
```

---

## 3. 会话数据备份

### 3.1 备份会话历史

```bash
# 备份所有会话
mkdir -p ~/.openclaw/backups/sessions
tar -czf ~/.openclaw/backups/sessions/sessions-$(date +%Y%m%d).tar.gz \
    -C ~/.openclaw agents/

# 仅备份活跃会话
ACTIVE_SESSIONS=$(openclaw sessions list --format json | jq -r '.[].id')
for session in $ACTIVE_SESSIONS; do
    cp ~/.openclaw/agents/main/sessions/$session.jsonl \
       ~/.openclaw/backups/sessions/ 2>/dev/null || true
done
```

### 3.2 导出会话为可读格式

```bash
#!/bin/bash
# 导出会话为 Markdown

SESSION_ID="main"
OUTPUT_FILE="$HOME/openclaw-session-$(date +%Y%m%d).md"

echo "# OpenClaw 会话导出" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "导出时间: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 读取会话日志
SESSION_FILE="$HOME/.openclaw/agents/main/sessions/$SESSION_ID.jsonl"
if [ -f "$SESSION_FILE" ]; then
    while IFS= read -r line; do
        echo "\`\`\`json" >> "$OUTPUT_FILE"
        echo "$line" | jq '.' >> "$OUTPUT_FILE"
        echo "\`\`\`" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done < "$SESSION_FILE"
fi

echo "会话已导出到: $OUTPUT_FILE"
```

---

## 4. 恢复操作

### 4.1 恢复配置文件

```bash
# 方法 1：从备份文件恢复
cp ~/.openclaw/backups/openclaw.json.20260205_120000 ~/.openclaw/openclaw.json

# 方法 2：从压缩包恢复
tar -xzf ~/.openclaw/backups/config-20260205.tar.gz -C /tmp/
cp /tmp/home/username/.openclaw/openclaw.json ~/.openclaw/

# 重启生效
openclaw gateway restart
```

### 4.2 恢复完整系统

```bash
#!/bin/bash
# 完整恢复脚本

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "用法: $0 <备份文件>"
    exit 1
fi

# 停止服务
openclaw gateway stop
pkill -9 -f openclaw

# 备份当前配置（以防万一）
mv ~/.openclaw ~/.openclaw.backup.before-restore.$(date +%Y%m%d_%H%M%S)

# 恢复备份
tar -xzf "$BACKUP_FILE" -C "$HOME"

# 修复权限
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json

# 重启服务
openclaw gateway start

echo "恢复完成"
```

### 4.3 从 git 历史恢复

```bash
cd ~/.openclaw

# 查看历史提交
git log --oneline

# 恢复到特定版本
git checkout <commit-hash> -- openclaw.json

# 或撤销最后一次修改
git checkout HEAD -- openclaw.json

# 放弃所有未提交修改
git checkout -- .
```

---

## 5. 迁移到新设备

### 5.1 导出配置

```bash
#!/bin/bash
# 迁移脚本

EXPORT_DIR="$HOME/openclaw-export-$(date +%Y%m%d)"
mkdir -p "$EXPORT_DIR"

# 复制必要文件
cp ~/.openclaw/openclaw.json "$EXPORT_DIR/"
cp -r ~/.openclaw/workspace "$EXPORT_DIR/" 2>/dev/null || true

# 导出已安装技能列表
openclaw skills list > "$EXPORT_DIR/skills.txt"

# 创建压缩包
tar -czf "$EXPORT_DIR.tar.gz" -C "$HOME" "$(basename $EXPORT_DIR)"

echo "迁移包已创建: $EXPORT_DIR.tar.gz"
echo "将此文件复制到新设备并解压到 ~/.openclaw/"
```

### 5.2 在新设备导入

```bash
#!/bin/bash
# 新设备导入

EXPORT_FILE="$1"

# 解压
tar -xzf "$EXPORT_FILE" -C /tmp/
EXPORT_DIR=$(ls /tmp | grep openclaw-export | head -1)

# 安装 OpenClaw
npm install -g openclaw@latest

# 创建配置目录
mkdir -p ~/.openclaw

# 复制配置
cp "/tmp/$EXPORT_DIR/openclaw.json" ~/.openclaw/
cp -r "/tmp/$EXPORT_DIR/workspace" ~/.openclaw/ 2>/dev/null || true

# 修复权限
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json

# 启动服务
openclaw gateway start

# 重新安装技能
while read skill; do
    openclaw skills install "$skill"
done < "/tmp/$EXPORT_DIR/skills.txt"

echo "迁移完成"
```

---

## 6. 自动备份工具

### 6.1 使用 restic 进行增量备份

```bash
# 安装 restic
brew install restic  # macOS
# apt install restic  # Ubuntu

# 初始化备份仓库
restic init --repo ~/backups/openclaw-restic

# 创建备份
restic backup ~/.openclaw \
    --repo ~/backups/openclaw-restic \
    --exclude='*.log' \
    --tag "$(date +%Y%m%d)"

# 查看备份历史
restic snapshots --repo ~/backups/openclaw-restic

# 恢复特定版本
restic restore <snapshot-id> --repo ~/backups/openclaw-restic \
    --target ~/openclaw-restored
```

### 6.2 使用 rclone 云备份

```bash
# 安装 rclone
brew install rclone

# 配置云存储
rclone config

# 创建备份脚本
cat > ~/.openclaw/backup-cloud.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf /tmp/openclaw-$DATE.tar.gz -C $HOME .openclaw/openclaw.json .openclaw/workspace/
rclone copy /tmp/openclaw-$DATE.tar.gz remote:backups/openclaw/
rm /tmp/openclaw-$DATE.tar.gz
EOF

chmod +x ~/.openclaw/backup-cloud.sh
```

---

## 7. 备份验证

### 7.1 测试备份完整性

```bash
#!/bin/bash
# 验证备份

BACKUP_FILE="$1"

# 测试压缩包完整性
tar -tzf "$BACKUP_FILE" > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ 压缩包完整性检查通过"
else
    echo "❌ 压缩包损坏"
    exit 1
fi

# 提取并验证配置
temp_dir=$(mktemp -d)
tar -xzf "$BACKUP_FILE" -C "$temp_dir"
CONFIG_FILE=$(find "$temp_dir" -name "openclaw.json" | head -1)

if python -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "✅ JSON 格式验证通过"
else
    echo "❌ JSON 格式错误"
    rm -rf "$temp_dir"
    exit 1
fi

rm -rf "$temp_dir"
echo "备份验证完成"
```

---

## 8. 灾难恢复流程

### 8.1 完整系统崩溃恢复

```bash
# 1. 重新安装 Node.js
brew install node  # macOS
# apt install nodejs npm  # Ubuntu

# 2. 重新安装 OpenClaw
npm install -g openclaw@latest

# 3. 恢复配置
mkdir -p ~/.openclaw
tar -xzf ~/backups/openclaw-latest.tar.gz -C ~/

# 4. 验证配置
openclaw doctor

# 5. 启动服务
openclaw gateway start
```

### 8.2 配置文件损坏恢复

```bash
# 1. 备份损坏的配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.corrupt.$(date +%Y%m%d)

# 2. 从最近的备份恢复
LATEST_BACKUP=$(ls -t ~/.openclaw/backups/openclaw.json.* | head -1)
cp "$LATEST_BACKUP" ~/.openclaw/openclaw.json

# 3. 如果没有备份，重新运行向导
openclaw onboard
```

---

## 9. 备份清单

定期执行：

- [ ] 配置修改后备份
- [ ] 每周完整备份
- [ ] 测试备份恢复流程
- [ ] 验证备份文件完整性
- [ ] 清理过期备份（保留30天）
- [ ] 异地备份（云存储）

---

## 10. 参考命令

```bash
# 查看备份列表
ls -lt ~/.openclaw/backups/

# 查看备份大小
du -sh ~/.openclaw/backups/*

# 清理旧备份
find ~/.openclaw/backups -mtime +30 -delete

# 检查备份频率
crontab -l | grep backup
```

---

*文档版本：v1.0*  
*最后更新：2026-02-06*
