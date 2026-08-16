#!/bin/bash
# rate-limit.sh - 5時間ブロック / 7日間ウィークリーのレート制限表示 v3.1
# 表示例: [Opus] 5h:34%(残2.1h) 7d:61%(残3.2d) | Context: 45%
#   使用率: 0-50%緑 / 50-80%黄 / 80%+赤
#   rate_limits はサブスクリプション（Pro/Max 等）利用時のみ提供される
#   値が無い場合はレート制限部分を非表示にする

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

# レート制限（5時間ブロック / 7日間ウィークリー）
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# カラー定義
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# 使用率に応じた色を返す
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

# resets_at (Unix epoch 秒) から残り時間を「2.1h」「3.2d」形式で返す
remaining() {
    local reset_at=$1
    local now diff
    now=$(date +%s)
    diff=$((reset_at - now))
    if [ "$diff" -le 0 ]; then
        echo "0h"
    elif [ "$diff" -lt 86400 ]; then
        awk -v d="$diff" 'BEGIN{printf "%.1fh", d/3600}'
    else
        awk -v d="$diff" 'BEGIN{printf "%.1fd", d/86400}'
    fi
}

# レート制限表示部の組み立て（値がある項目のみ）
# printf の書式文字列に埋め込むため % は %% にエスケープする
LIMITS=""
if [ -n "$FIVE_H_PCT" ]; then
    COLOR=$(pct_color "$FIVE_H_PCT")
    LIMITS="${COLOR}5h:${FIVE_H_PCT}%%${RESET}"
    [ -n "$FIVE_H_RESET" ] && LIMITS="${LIMITS}(残$(remaining "$FIVE_H_RESET"))"
fi
if [ -n "$WEEK_PCT" ]; then
    COLOR=$(pct_color "$WEEK_PCT")
    [ -n "$LIMITS" ] && LIMITS="${LIMITS} "
    LIMITS="${LIMITS}${COLOR}7d:${WEEK_PCT}%%${RESET}"
    [ -n "$WEEK_RESET" ] && LIMITS="${LIMITS}(残$(remaining "$WEEK_RESET"))"
fi

# コンテキスト色
CTX_COLOR=$(pct_color "$USAGE_INT")

if [ -n "$LIMITS" ]; then
    printf "${CTX_COLOR}[%s]${RESET} ${LIMITS} | Context: ${CTX_COLOR}%s%%${RESET}" "$MODEL" "$USAGE_INT"
else
    printf "${CTX_COLOR}[%s]${RESET} Context: ${CTX_COLOR}%s%%${RESET}" "$MODEL" "$USAGE_INT"
fi
