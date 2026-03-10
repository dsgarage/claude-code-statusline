#!/bin/bash
# minimal.sh - コンテキスト使用率のみ表示
# 表示例: Context: 45%

input=$(cat)

USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

echo "Context: ${USAGE}%"
