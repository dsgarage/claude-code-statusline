#!/bin/bash
# standard.sh - モデル + コンテキスト + コスト v3.0
# 表示例: [Opus] Context: 45% | $0.12

input=$(cat)

# モデル情報（複数のパスに対応）
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.name // .model // .modelName // "unknown"')
if [[ "$MODEL" == *"opus"* ]] || [[ "$MODEL" == *"Opus"* ]]; then MODEL="Opus"
elif [[ "$MODEL" == *"sonnet"* ]] || [[ "$MODEL" == *"Sonnet"* ]]; then MODEL="Sonnet"
elif [[ "$MODEL" == *"haiku"* ]] || [[ "$MODEL" == *"Haiku"* ]]; then MODEL="Haiku"
fi

# コンテキスト使用率（複数パス対応）
USAGE=$(echo "$input" | jq -r '(.context_window.used_percentage // .context.used_percentage // .contextUsage.percentage // .usage.percentage // 0)' | cut -d. -f1)

# コスト（複数パス対応）
COST=$(echo "$input" | jq -r '(.cost.total_cost_usd // .costs.total // .totalCost // .cost // 0)')

printf "[%s] Context: %s%% | \$%.2f" "$MODEL" "$USAGE" "$COST"
