# 健康报告输出模板

完成检查后，按以下格式输出报告：

```
# Claude Code 项目健康报告

## 📊 配置覆盖率

| 配置文件 | 状态 |
|----------|------|
| settings.json | ✅ 存在 |
| CLAUDE.md | ⚠️ 缺失 build 命令 |
| hooks/ | ❌ 缺失 |

## 🔴 高优先级问题

1. **CLAUDE.md 缺少测试命令**
   - 当前：未找到 `npm test` 或 `pytest` 说明
   - 修复：添加 "测试运行: `npm test`"

2. **permissions 使用硬编码而非通配符**
   - 文件：`.claude/settings.local.json`
   - 修复：改为 `Bash(npm *)`

## ⚠️ 中优先级建议

1. **缺少 PostToolUse 格式化 hook**
   - 建议：添加 ESLint/Prettier 自动格式化

2. **CLAUDE.md 超过 200 行**
   - 当前：350 行
   - 建议：拆分为 `.claude/rules/` 子规则

## ✅ 良好实践

1. 使用了通配符权限：`Bash(python3 *)`
2. 配置了 thinking mode
3. 有完整的 hooks 脚本

## 📋 修复优先级

1. **[P0]** 修复 CLAUDE.md 缺少测试命令
2. **[P1]** 将硬编码权限改为通配符
3. **[P2]** 添加格式化 hook
```
