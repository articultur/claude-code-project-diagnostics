# Claude Code 最佳实践参考

## settings.json / settings.local.json 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **permissions.allow** | 使用通配符而非硬编码命令 | ⚠️ 警告 |
| **permissions.allow** | 避免 `*` 全通配符，结合具体需要 | 🔴 高 |
| **model** | 明确配置 thinking/plan model | ℹ️ 低 |
| **output.style** | 设置为 `explanatory` 方便理解 | ℹ️ 低 |
| **features.thinking** | 启用以查看推理过程 | ℹ️ 低 |
| **features.outputStyles** | 包含 `explanatory` | ℹ️ 低 |

### 权限配置示例

❌ 不推荐（硬编码）：
```json
{
  "permissions": {
    "allow": ["Bash(npm install:*)", "Bash(git clone:*)", "WebFetch(domain:example.com)"]
  }
}
```

✅ 推荐（通配符模式）：
```json
{
  "permissions": {
    "allow": [
      "Bash(npm *)",
      "Bash(git *)",
      "WebFetch(domain:*)"
    ]
  }
}
```

## CLAUDE.md 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **文件长度** | 建议 < 200 行 | ⚠️ 警告 |
| **规则组织** | 复杂项目使用 `.claude/rules/` | ⚠️ 警告 |
| **重要规则** | 使用 `<important if="...">` 标签 | ⚠️ 警告 |
| **必需命令** | 包含 build/test/setup 命令 | 🔴 高 |

### CLAUDE.md 必须包含
1. 项目结构说明
2. build/test/run 命令
3. 开发流程规范（如有）
4. 关键约定和禁忌

## Hooks 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **PostToolUse 格式化** | 建议添加自动格式化 hook | ℹ️ 低 |
| **PreToolUse 权限路由** | 可自动审批安全操作 | ℹ️ 低 |
| **Stop hook** | 建议添加完成前验证 | ℹ️ 低 |

### 推荐的 hooks 配置
- `PostToolUse`: 自动格式化（ESLint/Prettier）
- `Stop`: 提交前检查、验证

## Commands 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **存在性** | 重复性工作应创建 command | ⚠️ 警告 |
| **命名** | 描述性名称（如 `/techdebt`, `/deploy`) | ℹ️ 低 |

### Command 最佳实践（Boris Cherny）
- 每天重复 >1 次的工作 → 应该是 command
- Command 优于 subagent（更轻量）
- Command 保存在 `.claude/commands/`，可提交到 git

## Skills 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **结构** | 使用 `references/`、`scripts/` 子目录 | ⚠️ 警告 |
| **Gotchas** | 包含 Claude 常见失败点 | ⚠️ 警告 |
| **描述** | description 是触发器，不是摘要 | ⚠️ 警告 |
| **渐进披露** | SKILL.md < 500 行，详细内容在 references/ | ℹ️ 低 |

## MCP 配置检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **mcpServers** | 验证配置的服务器可连接 | ⚠️ 警告 |
| **必要性** | 仅保留真正需要的 MCP | ℹ️ 低 |

## Agents 检查项

| 检查项 | 最佳实践 | 严重程度 |
|--------|----------|----------|
| **专用性** | 功能专用 agent 优于通用 agent | ⚠️ 警告 |
| **上下文** | 包含必要的 skills/context | ℹ️ 低 |

### Agent 最佳实践（Boris Cherny）
- Feature-specific subagents > 通用 qa/backend engineer
- Subagent 应有专属 skills（渐进披露）
