---
name: claude-code-project-diagnostics
description: This skill should be used when the user asks to "检查配置", "检查项目", "健康检查", "诊断问题", "分析 .claude 配置", "审查 CLAUDE.md", "检查 skill", "检查 hook", "配置有什么问题", or when they want to audit, diagnose, or improve their Claude Code project setup. Also trigger when the user mentions validating .claude/, settings.json, CLAUDE.md, hooks, commands, skills, or MCP configuration.
---

# Project Health Checker

检查 Claude Code 项目配置的健康状况，基于 [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)。

## 执行流程

1. 读取配置：使用 Glob/Read 扫描所有配置文件
2. 逐项检查：按清单验证（详见 `references/best-practices.md`）
3. 分类输出：按严重程度分组（🔴高/⚠️中/ℹ️低）
4. 提供修复：每个问题给出具体修复建议

## 为什么需要健康检查

Claude Code 项目配置会随时间积累技术债务：
- **权限配置**不当会导致重复授权提示或安全风险
- **CLAUDE.md 过长**（>200行）会降低模型遵循率
- **缺少 hooks** 会遗漏自动格式化、验证等效率提升
- **Skill 结构**不规范会导致触发失败或上下文浪费

定期健康检查可及早发现并修复这些问题。

## 检查清单

### 1. 配置文件存在性

**Why**: 基础配置文件缺失意味着项目未正确初始化，Claude 无法获取关键上下文。

```bash
ls -la .claude/ .claude/settings*.json .claude/hooks/ .claude/commands/ .claude/skills/ .claude/agents/ CLAUDE.md .mcp.json
```

### 2. settings.json

**Why**: 合理的 permissions 配置减少重复授权；明确的 model/output 设置确保一致的交互体验。

检查项：**permissions**（通配符>硬编码）、**model**（thinking/plan）、**output.style**（explanatory）、**features.thinking**、**features.outputStyles**

### 3. settings.local.json

**Why**: 此文件覆盖全局设置，适合项目级覆盖。敏感信息应放此处而非 settings.json（应已在 .gitignore）。

检查项同 settings.json。

### 4. CLAUDE.md

**Why**: CLAUDE.md >200 行会被模型部分忽略（上下文限制）。`<important>` 标签确保关键规则在复杂提示下仍被遵循。

检查项：**文件长度**（<200行）、**规则组织**（`.claude/rules/`）、**重要规则**（`<important if="...">`）、**必需命令**（build/test/setup）

必须包含：项目结构、build/test/run 命令、开发流程、关键约定。

### 5. Hooks

**Why**: Hooks 自动化重复任务（格式化、验证），减少人工干预。PostToolUse 格式化确保代码风格一致；Stop hook 在会话结束前捕获问题。

检查项：**PostToolUse**（自动格式化）、**PreToolUse**（权限路由）、**Stop**（完成验证）

### 6. Commands

**Why**: Command 比 Subagent 更轻量，适合每天重复>1次的任务。命名清晰的 command（如 `/techdebt`）便于团队共享。

检查项：重复工作→command、描述性命名

**Boris Cherny 原则**: Command > Subagent > Skill，按需升级。

### 7. Skills

**Why**: 结构良好的 skill（references/、渐进披露）减少上下文浪费；description 是触发器而非摘要，决定何时激活。

检查项：**结构**（references/scripts）、**Gotchas**（常见失败点）、**description**（触发器≠摘要）、**渐进披露**（SKILL.md<500行）

### 8. MCP 配置

**Why**: 未使用的 MCP 服务器浪费启动时间和资源。无效的 mcpServers 配置会导致错误提示。

检查项：**mcpServers**（可连接性）、**必要性**（精简）

### 9. Agents

**Why**: 功能专用的 agent（如 `security-reviewer`）比通用 agent 输出质量更高。专属 skills 提供渐进披露，避免上下文膨胀。

检查项：**专用性**（功能专用>通用）、**上下文**（专属 skills）

**Boris Cherny 原则**: Feature-specific subagents > 通用 qa/backend engineer

## 输出格式

报告结构：
- 📊 配置覆盖率表格
- 🔴 高优先级（缺少必需命令、硬编码权限）
- ⚠️ 中优先级（缺少 hook、文件过长）
- ✅ 良好实践
- 📋 修复优先级

详见 `references/output-template.md`

## Scripts

**`scripts/health-check.sh`** - 自动化健康检查脚本
- 检查配置文件存在性
- 检测硬编码权限 vs 通配符
- 验证 CLAUDE.md 行数
- 用法: `./scripts/health-check.sh [project-path]`

## Templates

**`templates/CLAUDE.md.template`** - CLAUDE.md 模板（符合 <200 行规范）

**`templates/hooks.json`** - 推荐 hook 配置模板

## Gotchas

常见陷阱和注意事项：

1. **jq 依赖**: `scripts/health-check.sh` 需要 jq 工具进行 JSON 验证。如未安装，JSON 检查将被跳过
2. **settings.local.json**: 此文件通常包含敏感信息，不应提交到 git（应已在 .gitignore 中）
3. **CLAUDE.md 行数**: 200/300 行是建议值，非硬性限制。复杂项目可适当放宽
4. **Hooks schema**: Claude Code hooks 配置格式可能因版本而异，模板基于当前文档
5. **脚本 vs 手动检查**: 脚本提供快速扫描，手动 Glob/Read 检查可进行更深入分析

## Examples

使用示例：
- **`examples/example-healthy-project.md`** - 健康项目的检查结果示例
- **`examples/example-problematic-project.md`** - 问题项目的检查结果及修复建议

## 参考资源

| 文件 | 内容 |
|------|------|
| `references/best-practices.md` | 详细检查表格 |
| `references/output-template.md` | 报告模板 |
| `evals/evals.json` | 测试用例 |
