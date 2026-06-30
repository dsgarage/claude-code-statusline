#!/bin/bash
# standard-color.sh - モデル + コンテキスト（色分け） + コスト v3.0
# 表示例: [Opus] Context: 45% | $0.12
#   0-50%: 緑 / 50-80%: 黄 / 80%+: 赤

input=$(cat)

# モデル情報（複数のパスに対応）
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.name // .model // .modelName // "unknown"')
if [[ "$MODEL" == *"opus"* ]] || [[ "$MODEL" == *"Opus"* ]]; then MODEL="Opus"
elif [[ "$MODEL" == *"sonnet"* ]] || [[ "$MODEL" == *"Sonnet"* ]]; then MODEL="Sonnet"
elif [[ "$MODEL" == *"haiku"* ]] || [[ "$MODEL" == *"Haiku"* ]]; then MODEL="Haiku"
fi

# コンテキスト使用率（複数パス対応）
USAGE=$(echo "$input" | jq -r '(.context_window.used_percentage // .context.used_percentage // .contextUsage.percentage // .usage.percentage // 0)')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)

# コスト（複数パス対応）
COST=$(echo "$input" | jq -r '(.cost.total_cost_usd // .costs.total // .totalCost // .cost // 0)')

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
