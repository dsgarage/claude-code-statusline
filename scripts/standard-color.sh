#!/bin/bash
# standard-color.sh - モデル + コンテキスト（色分け） + コスト v3.1
# 表示例: [Opus] Context: 45% | $0.12 | 5h:34% 7d:61%
#   0-50%: 緑 / 50-80%: 黄 / 80%+: 赤
#   5h/7d: レート制限使用率（サブスクリプション利用時のみ表示）

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

# レート制限（5時間ブロック / 7日間ウィークリー）
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# 使用率に応じた色を返す（0-50%緑 / 50-80%黄 / 80%+赤）
pct_color() {
    local pct=$1
    if [ "$pct" -lt 50 ]; then
        echo "$GREEN"
    elif [ "$pct" -lt 80 ]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

COLOR=$(pct_color "$USAGE_INT")

# レート制限表示部（値がある項目のみ）
# printf の書式文字列に埋め込むため % は %% にエスケープする
LIMITS=""
if [ -n "$FIVE_H_PCT" ]; then
    LIMITS="$(pct_color "$FIVE_H_PCT")5h:${FIVE_H_PCT}%%${RESET}"
fi
if [ -n "$WEEK_PCT" ]; then
    [ -n "$LIMITS" ] && LIMITS="${LIMITS} "
    LIMITS="${LIMITS}$(pct_color "$WEEK_PCT")7d:${WEEK_PCT}%%${RESET}"
fi

printf "${COLOR}[%s]${RESET} Context: ${COLOR}%s%%${RESET} | \$%.2f" "$MODEL" "$USAGE_INT" "$COST"
if [ -n "$LIMITS" ]; then
    printf " | ${LIMITS}"
fi
