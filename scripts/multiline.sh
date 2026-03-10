#!/bin/bash
# multiline.sh - 2行表示（上: Git + コード変更 / 下: コンテキストバー + コスト）
# 表示例:
#   main | +245 -89
#   [████████░░░░░░░░░░░░] 45% | $0.12

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

WORK_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
BRANCH=$(cd "$WORK_DIR" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")

# プログレスバー
BAR_WIDTH=20
FILLED=$((USAGE_INT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
for ((i = 0; i < FILLED; i++)); do BAR+="█"; done
for ((i = 0; i < EMPTY; i++)); do BAR+="░"; done

# カラー
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

if [ "$USAGE_INT" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$USAGE_INT" -lt 80 ]; then
    CTX_COLOR="\033[33m"
else
    CTX_COLOR="$RED"
fi

# 1行目: Git + コード変更
printf "${CYAN}%s${RESET} | ${GREEN}+%s${RESET} ${RED}-%s${RESET}\n" "$BRANCH" "$ADDED" "$REMOVED"
# 2行目: プログレスバー + コスト
printf "${CTX_COLOR}[%s]${RESET} %s%% | [%s] \$%.2f" "$BAR" "$USAGE_INT" "$MODEL" "$COST"
