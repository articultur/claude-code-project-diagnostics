#!/bin/bash
# Claude Code Project Health Check Script
# Usage: ./health-check.sh [project-path]

set -e

PROJECT_DIR="${1:-.}"
WARNINGS=0
ERRORS=0

# Check for jq dependency
check_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  警告: jq 未安装，JSON 检查将被跳过"
        echo "   安装 jq 以获得完整检查功能: https://stedolan.github.io/jq/download/"
        echo ""
        return 1
    fi
    return 0
}

JQ_AVAILABLE=false
if check_jq; then
    JQ_AVAILABLE=true
fi

echo "🔍 Claude Code 项目健康检查"
echo "================================"
echo ""

# Helper functions
check_file() {
    if [ -f "$PROJECT_DIR/$1" ]; then
        echo "✅ $1"
        return 0
    else
        echo "❌ $1 (缺失)"
        return 1
    fi
}

check_dir() {
    if [ -d "$PROJECT_DIR/$1" ]; then
        echo "✅ $1/"
        return 0
    else
        echo "❌ $1/ (缺失)"
        return 1
    fi
}

warn() {
    echo "⚠️  $1"
    ((WARNINGS++)) || true
}

error() {
    echo "🔴 $1"
    ((ERRORS++)) || true
}

# 1. Check config file existence
echo "📁 配置文件存在性检查"
echo "--------------------------------"

check_file ".claude/settings.json" || true
check_file ".claude/settings.local.json" || true
check_dir ".claude/hooks" || true
check_dir ".claude/commands" || true
check_dir ".claude/skills" || true
check_dir ".claude/agents" || true
check_file "CLAUDE.md" || true
check_file ".mcp.json" || true
echo ""

# 2. Check settings.json
echo "⚙️  settings.json 检查"
echo "--------------------------------"

SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ] && [ "$JQ_AVAILABLE" = true ]; then
    # Check JSON validity
    if ! jq empty "$SETTINGS_FILE" 2>/dev/null; then
        error "settings.json JSON 格式无效"
    else
        echo "✅ JSON 格式有效"

        # Check permissions
        if jq -e '.permissions' "$SETTINGS_FILE" >/dev/null 2>&1; then
            # Check for hardcoded patterns (bad)
            HARDcoded=$(jq -r '.permissions.allow[]?' "$SETTINGS_FILE" 2>/dev/null | grep -E '^Bash\((npm install|git clone|pip install):\*\)$' || true)
            if [ -n "$HARDcoded" ]; then
                warn "发现硬编码权限，建议使用通配符: $HARDcoded"
            fi

            # Check for wildcard patterns (good)
            WILDCARD=$(jq -r '.permissions.allow[]?' "$SETTINGS_FILE" 2>/dev/null | grep -E '^Bash\([a-z]+ \*\)$' || true)
            if [ -n "$WILDCARD" ]; then
                echo "✅ 使用通配符权限"
            fi

            # Check for dangerous all-wildcard
            if jq -r '.permissions.allow[]?' "$SETTINGS_FILE" 2>/dev/null | grep -qE '^Bash\(\*\)$'; then
                error "危险: 全通配符权限 Bash(*)"
            fi
        fi

        # Check model configuration
        if ! jq -e '.model' "$SETTINGS_FILE" >/dev/null 2>&1; then
            warn "未配置 model"
        fi

        # Check features
        if ! jq -e '.features' "$SETTINGS_FILE" >/dev/null 2>&1; then
            warn "未配置 features"
        fi
    fi
elif [ -f "$SETTINGS_FILE" ] && [ "$JQ_AVAILABLE" = false ]; then
    echo "ℹ️  settings.json 存在 (jq 不可用，跳过详细检查)"
else
    error "settings.json 缺失"
fi
echo ""

# 3. Check CLAUDE.md
echo "📄 CLAUDE.md 检查"
echo "--------------------------------"

CLAUDE_FILE="$PROJECT_DIR/CLAUDE.md"
if [ -f "$CLAUDE_FILE" ]; then
    LINE_COUNT=$(wc -l < "$CLAUDE_FILE")
    echo "行数: $LINE_COUNT"

    if [ "$LINE_COUNT" -gt 300 ]; then
        error "超过 300 行，强烈建议拆分到 .claude/rules/"
    elif [ "$LINE_COUNT" -gt 200 ]; then
        warn "超过 200 行，建议拆分到 .claude/rules/"
    else
        echo "✅ 行数正常"
    fi

    # Check for essential content
    if grep -qiE "build|test|setup|run" "$CLAUDE_FILE" 2>/dev/null; then
        echo "✅ 包含构建/测试命令"
    else
        warn "缺少构建/测试命令"
    fi

    # Check for important tags
    if grep -q '<important' "$CLAUDE_FILE" 2>/dev/null; then
        echo "✅ 使用 <important> 标签"
    else
        warn "未使用 <important> 标签标记关键规则"
    fi

    # Check for .claude/rules/ if CLAUDE.md is too long
    if [ "$LINE_COUNT" -gt 200 ] && [ ! -d "$PROJECT_DIR/.claude/rules" ]; then
        warn "建议创建 .claude/rules/ 目录拆分规则"
    fi
else
    error "CLAUDE.md 缺失"
fi
echo ""

# 4. Check Skills
echo "🎓 Skills 检查"
echo "--------------------------------"

SKILLS_DIR="$PROJECT_DIR/.claude/skills"
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l)
    echo "发现 $SKILL_COUNT 个 skill"

    # Check each skill structure
    while IFS= read -r skill_file; do
        SKILL_NAME=$(basename "$(dirname "$skill_file")")
        echo "  📦 $SKILL_NAME"

        # Check frontmatter
        if ! head -5 "$skill_file" | grep -q '^---$'; then
            warn "  $SKILL_NAME: 缺少 YAML frontmatter"
        fi

        # Check description field
        if ! head -10 "$skill_file" | grep -q 'description:'; then
            warn "  $SKILL_NAME: 缺少 description 字段"
        fi

        # Check for references/ directory
        SKILL_DIR=$(dirname "$skill_file")
        if [ ! -d "$SKILL_DIR/references" ]; then
            warn "  $SKILL_NAME: 缺少 references/ 目录"
        fi

        # Check SKILL.md line count
        SKILL_LINES=$(wc -l < "$skill_file")
        if [ "$SKILL_LINES" -gt 500 ]; then
            warn "  $SKILL_NAME: SKILL.md $SKILL_LINES 行，建议拆分"
        fi
    done < <(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null)
else
    echo "ℹ️  无 skills 目录"
fi
echo ""

# 5. Check MCP configuration
echo "🔌 MCP 配置检查"
echo "--------------------------------"

MCP_FILE="$PROJECT_DIR/.mcp.json"
if [ -f "$MCP_FILE" ]; then
    if ! jq empty "$MCP_FILE" 2>/dev/null; then
        error ".mcp.json JSON 格式无效"
    else
        echo "✅ .mcp.json 格式有效"

        SERVER_COUNT=$(jq '.mcpServers | length' "$MCP_FILE" 2>/dev/null || echo "0")
        echo "配置服务器数: $SERVER_COUNT"

        if [ "$SERVER_COUNT" -eq 0 ]; then
            warn "未配置任何 MCP 服务器"
        fi
    fi
else
    echo "ℹ️  无 .mcp.json 配置"
fi
echo ""

# 6. Check Hooks
echo "🪝 Hooks 检查"
echo "--------------------------------"

HOOKS_FILE="$PROJECT_DIR/.claude/hooks.json"
HOOKS_DIR="$PROJECT_DIR/.claude/hooks"

if [ -f "$HOOKS_FILE" ]; then
    if ! jq empty "$HOOKS_FILE" 2>/dev/null; then
        error "hooks.json JSON 格式无效"
    else
        echo "✅ hooks.json 格式有效"

        # Check for recommended hooks (schema: .hooks.PostToolUse[], .hooks.PreToolUse[], .hooks.Stop[])
        if jq -e '.hooks.PostToolUse' "$HOOKS_FILE" >/dev/null 2>&1 && [ "$(jq '.hooks.PostToolUse | length' "$HOOKS_FILE" 2>/dev/null)" != "0" ]; then
            echo "✅ 配置了 PostToolUse hook"
        else
            warn "未配置 PostToolUse hook（建议添加格式化）"
        fi

        if jq -e '.hooks.Stop' "$HOOKS_FILE" >/dev/null 2>&1 && [ "$(jq '.hooks.Stop | length' "$HOOKS_FILE" 2>/dev/null)" != "0" ]; then
            echo "✅ 配置了 Stop hook"
        else
            warn "未配置 Stop hook（建议添加验证）"
        fi
    fi
elif [ -d "$HOOKS_DIR" ]; then
    HOOK_COUNT=$(find "$HOOKS_DIR" -type f | wc -l)
    echo "发现 $HOOK_COUNT 个 hook 文件"
else
    warn "无 hooks 配置"
fi
echo ""

# 7. Summary
echo "================================"
echo "📊 检查摘要"
echo "================================"
echo "错误: $ERRORS"
echo "警告: $WARNINGS"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 项目配置健康！"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  项目基本健康，建议处理警告"
else
    echo "🔴 项目存在需要修复的问题"
fi

# Exit with error count (useful for CI pipelines)
exit $ERRORS
