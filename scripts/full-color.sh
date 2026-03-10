#!/bin/bash
# full-color.sh - 全部入りカラー版
# 表示例: [Opus] Context: 45% | $0.12 | main | +245 -89
#   コンテキスト: 0-50%緑 / 50-80%黄 / 80%+赤
#   コスト: $1未満緑 / $1-5黄 / $5+赤
#   コード変更: 追加=緑 / 削除=赤

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_INT=$(echo "$COST" | cut -d. -f1)
ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

WORK_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
BRANCH=$(cd "$WORK_DIR" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")

# カラー定義
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"

# コンテキスト色
if [ "$USAGE_INT" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$USAGE_INT" -lt 80 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$RED"
fi

# コスト色
if [ "$COST_INT" -lt 1 ]; then
    COST_COLOR="$GREEN"
elif [ "$COST_INT" -lt 5 ]; then
    COST_COLOR="$YELLOW"
else
    COST_COLOR="$RED"
fi

printf "${CTX_COLOR}[%s]${RESET} Context: ${CTX_COLOR}%s%%${RESET} | ${COST_COLOR}\$%.2f${RESET} | ${CYAN}%s${RESET} | ${GREEN}+%s${RESET} ${RED}-%s${RESET}" \
    "$MODEL" "$USAGE_INT" "$COST" "$BRANCH" "$ADDED" "$REMOVED"
