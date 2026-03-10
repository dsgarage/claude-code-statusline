#!/bin/bash
# cost-tracker.sh - コスト追跡重視
# 表示例: $0.12 | In:65K Out:12K Cache:20K | Context: 45%

input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.output_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.cache_creation_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.cache_read_tokens // 0')

# トークン数を K 表記に変換
format_k() {
    local n=$1
    if [ "$n" -ge 1000 ]; then
        echo "$((n / 1000))K"
    else
        echo "$n"
    fi
}

IN_K=$(format_k "$INPUT_TOKENS")
OUT_K=$(format_k "$OUTPUT_TOKENS")
CACHE_K=$(format_k "$((CACHE_CREATE + CACHE_READ))")

# コスト色
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

COST_INT=$(echo "$COST" | cut -d. -f1)
if [ "$COST_INT" -lt 1 ]; then
    COST_COLOR="$GREEN"
elif [ "$COST_INT" -lt 5 ]; then
    COST_COLOR="$YELLOW"
else
    COST_COLOR="$RED"
fi

printf "${COST_COLOR}\$%.2f${RESET} | In:%s Out:%s Cache:%s | Context: %s%%" "$COST" "$IN_K" "$OUT_K" "$CACHE_K" "$USAGE"
