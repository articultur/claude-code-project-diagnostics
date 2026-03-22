# 示例：健康项目检查结果

## 输入

用户提问：
```
检查当前项目的配置
```

项目结构：
```
my-project/
├── .claude/
│   ├── settings.json       # 配置正确
│   ├── hooks.json          # 配置了 PostToolUse 和 Stop
│   ├── commands/           # 有 3 个命令
│   ├── skills/             # 有 2 个 skill
│   └── agents/             # 有 1 个 agent
├── CLAUDE.md               # 150 行，包含 build/test/run
└── .mcp.json               # 配置了 2 个 MCP 服务器
```

## 预期输出

```markdown
# Claude Code 项目健康报告

## 📊 配置覆盖率

| 配置文件 | 状态 |
|----------|------|
| settings.json | ✅ 存在 |
| CLAUDE.md | ✅ 存在 |
| hooks/ | ✅ 存在 |
| commands/ | ✅ 存在 |
| skills/ | ✅ 存在 |
| agents/ | ✅ 存在 |
| .mcp.json | ✅ 存在 |

## 🔴 高优先级问题

无

## ⚠️ 中优先级建议

1. **缺少 PreToolUse hook**
   - 建议：添加权限路由自动化

## ✅ 良好实践

1. 使用了通配符权限：`Bash(npm *)`
2. CLAUDE.md 行数正常（150 行）
3. 配置了 thinking mode
4. 包含完整的命令说明

## 📋 修复优先级

1. **[P1]** 添加 PreToolUse hook（可选）
```

## 关键检查点

- ✅ settings.json 使用通配符权限
- ✅ CLAUDE.md < 200 行
- ✅ 包含 build/test/run 命令
- ✅ 使用 `<important>` 标签
- ✅ hooks 配置完整
