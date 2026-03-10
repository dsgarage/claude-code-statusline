#!/bin/bash
# full.sh - 全部入り（モデル + コンテキスト + コスト + Git + コード変更量）
# 表示例: [Opus] Context: 45% | $0.12 | main | +245 -89

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# 作業ディレクトリから Git ブランチ取得
WORK_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
BRANCH=$(cd "$WORK_DIR" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")

printf "[%s] Context: %s%% | \$%.2f | %s | +%s -%s" "$MODEL" "$USAGE" "$COST" "$BRANCH" "$ADDED" "$REMOVED"
