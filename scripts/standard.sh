#!/bin/bash
# standard.sh - モデル + コンテキスト + コスト
# 表示例: [Opus] Context: 45% | $0.12

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

printf "[%s] Context: %s%% | \$%.2f" "$MODEL" "$USAGE" "$COST"
