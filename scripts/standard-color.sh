#!/bin/bash
# standard-color.sh - モデル + コンテキスト（色分け） + コスト
# 表示例: [Opus] Context: 45% | $0.12
#   0-50%: 緑 / 50-80%: 黄 / 80%+: 赤

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# コンテキスト使用率で色分け
if [ "$USAGE_INT" -lt 50 ]; then
    COLOR="\033[32m"  # 緑
elif [ "$USAGE_INT" -lt 80 ]; then
    COLOR="\033[33m"  # 黄
else
    COLOR="\033[31m"  # 赤
fi
RESET="\033[0m"

printf "${COLOR}[%s]${RESET} Context: ${COLOR}%s%%${RESET} | \$%.2f" "$MODEL" "$USAGE_INT" "$COST"
