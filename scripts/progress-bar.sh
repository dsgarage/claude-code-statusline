#!/bin/bash
# progress-bar.sh - プログレスバーでコンテキスト使用率を表示
# 表示例: [Opus] [████████░░░░░░░░░░░░] 45% | $0.12

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# プログレスバー生成（幅20）
BAR_WIDTH=20
FILLED=$((USAGE_INT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

BAR=""
for ((i = 0; i < FILLED; i++)); do BAR+="█"; done
for ((i = 0; i < EMPTY; i++)); do BAR+="░"; done

# 色分け
if [ "$USAGE_INT" -lt 50 ]; then
    COLOR="\033[32m"
elif [ "$USAGE_INT" -lt 80 ]; then
    COLOR="\033[33m"
else
    COLOR="\033[31m"
fi
RESET="\033[0m"

printf "[%s] ${COLOR}[%s]${RESET} %s%% | \$%.2f" "$MODEL" "$BAR" "$USAGE_INT" "$COST"
