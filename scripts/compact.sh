#!/bin/bash
# compact.sh - 最小幅コンパクト表示（狭いターミナル向け）
# 表示例: O4|45%|$0.12

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# モデル名を短縮
case "$MODEL" in
    *Opus*)   SHORT="Op" ;;
    *Sonnet*) SHORT="So" ;;
    *Haiku*)  SHORT="Ha" ;;
    *)        SHORT="${MODEL:0:2}" ;;
esac

printf "%s|%s%%|\$%.2f" "$SHORT" "$USAGE" "$COST"
