# 示例：问题项目检查结果

## 输入

用户提问：
```
帮我看看这个项目有什么配置问题
```

项目结构：
```
problem-project/
├── .claude/
│   └── settings.json       # 硬编码权限 + 全通配符
├── CLAUDE.md               # 350 行，过长
└── .mcp.json               # 无效配置
```

## 预期输出

```markdown
# Claude Code 项目健康报告

## 📊 配置覆盖率

| 配置文件 | 状态 |
|----------|------|
| settings.json | ✅ 存在 |
| CLAUDE.md | ⚠️ 超过 200 行 |
| hooks/ | ❌ 缺失 |
| commands/ | ❌ 缺失 |
| skills/ | ❌ 缺失 |
| .mcp.json | ⚠️ 配置无效 |

## 🔴 高优先级问题

1. **settings.json 使用危险的全通配符权限**
   - 当前：`Bash(*)`
   - 修复：改为具体的命令通配符，如 `Bash(npm *)`、`Bash(git *)`

2. **CLAUDE.md 缺少必需的命令说明**
   - 当前：未找到 build/test/run 说明
   - 修复：添加 "## 开发命令" 章节

## ⚠️ 中优先级建议

1. **CLAUDE.md 超过 200 行**
   - 当前：350 行
   - 建议：拆分到 `.claude/rules/` 目录

2. **使用硬编码权限模式**
   - 当前：`Bash(npm install:*)`
   - 建议：改为 `Bash(npm *)`

3. **缺少 hooks 配置**
   - 建议：添加 `.claude/hooks.json` 配置自动格式化

## ✅ 良好实践

1. 配置了 model 和 output.style

## 📋 修复优先级

1. **[P0]** 移除 `Bash(*)` 全通配符权限
2. **[P0]** 在 CLAUDE.md 中添加 build/test/run 命令
3. **[P1]** 将 CLAUDE.md 拆分到 .claude/rules/
4. **[P1]** 硬编码权限改为通配符
5. **[P2]** 添加 hooks 配置
```

## 修复建议

### 修复 settings.json

❌ 当前配置：
```json
{
  "permissions": {
    "allow": ["Bash(npm install:*)", "Bash(git clone:*)", "Bash(*)"]
  }
}
```

✅ 修复后：
```json
{
  "model": "claude-opus",
  "permissions": {
    "allow": ["Bash(npm *)", "Bash(git *)", "Bash(python3 *)"]
  },
  "features": {
    "thinking": true,
    "outputStyles": ["explanatory"]
  },
  "output": {
    "style": "explanatory"
  }
}
```

### 修复 CLAUDE.md

将 350 行的 CLAUDE.md 拆分为：
- `CLAUDE.md`（100 行）：核心结构 + 命令
- `.claude/rules/coding.md`（100 行）：编码规范
- `.claude/rules/deployment.md`（100 行）：部署流程
- `.claude/rules/testing.md`（50 行）：测试规范

### 添加 hooks.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {"tool": "Bash", "command": "npm run format"},
        "description": "Auto-format after running formatter"
      }
    ],
    "Stop": [
      {"description": "Validate before completing session"}
    ]
  }
}
```
