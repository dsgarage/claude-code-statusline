#!/bin/bash
# git-focused.sh - Git 情報重視
# 表示例: main | M:3 U:1 S:2 | Context: 45%

input=$(cat)

USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
WORK_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')

# Git 情報取得
cd "$WORK_DIR" 2>/dev/null || exit 0
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
MODIFIED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

# 色
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

printf "${CYAN}%s${RESET}" "$BRANCH"

# 変更がある場合のみ表示
CHANGES=""
[ "$MODIFIED" -gt 0 ] && CHANGES+=" ${YELLOW}M:${MODIFIED}${RESET}"
[ "$UNTRACKED" -gt 0 ] && CHANGES+=" ${RED}U:${UNTRACKED}${RESET}"
[ "$STAGED" -gt 0 ] && CHANGES+=" ${GREEN}S:${STAGED}${RESET}"

if [ -n "$CHANGES" ]; then
    printf " |%s" "$CHANGES"
fi

printf " | Context: %s%%" "$USAGE"
