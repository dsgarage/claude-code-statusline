#!/bin/bash
# tokens-detail.sh - トークン消費の内訳を詳細表示
# 表示例: [Opus] In:65K Create:15K Read:5K Out:12K (48%) | $0.12

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
SIZE=$(echo "$input" | jq -r '.context_window.size // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.output_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.cache_creation_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.cache_read_tokens // 0')

# K 表記
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
CC_K=$(format_k "$CACHE_CREATE")
CR_K=$(format_k "$CACHE_READ")
SIZE_K=$(format_k "$SIZE")

# カラー
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

if [ "$USAGE_INT" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$USAGE_INT" -lt 80 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$RED"
fi

printf "${CYAN}[%s]${RESET} In:%s Create:%s Read:%s Out:%s ${CTX_COLOR}(%s%%)${RESET} | \$%.2f" \
    "$MODEL" "$IN_K" "$CC_K" "$CR_K" "$OUT_K" "$USAGE" "$COST"
