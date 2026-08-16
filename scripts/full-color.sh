#!/bin/bash
# full-color.sh - 全部入りカラー版 v3.1
# 表示例: [Opus] Context: 45% | $0.12 | main | +245 -89 | 5h:34% 7d:61%
#   コンテキスト: 0-50%緑 / 50-80%黄 / 80%+赤
#   コスト: $1未満緑 / $1-5黄 / $5+赤
#   コード変更: 追加=緑 / 削除=赤
#   5h/7d: レート制限使用率（サブスクリプション利用時のみ表示）

input=$(cat)

# モデル情報（複数のパスに対応）
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.name // .model // .modelName // "unknown"')
# モデル名の整形
if [[ "$MODEL" == *"opus"* ]] || [[ "$MODEL" == *"Opus"* ]]; then MODEL="Opus"
elif [[ "$MODEL" == *"sonnet"* ]] || [[ "$MODEL" == *"Sonnet"* ]]; then MODEL="Sonnet"
elif [[ "$MODEL" == *"haiku"* ]] || [[ "$MODEL" == *"Haiku"* ]]; then MODEL="Haiku"
fi

# 各メトリクスの取得（複数パス対応）
USAGE=$(echo "$input" | jq -r '(.context_window.used_percentage // .context.used_percentage // .contextUsage.percentage // .usage.percentage // 0)')
USAGE_INT=$(echo "$USAGE" | cut -d. -f1)
COST=$(echo "$input" | jq -r '(.cost.total_cost_usd // .costs.total // .totalCost // .cost // 0)')
COST_INT=$(echo "$COST" | cut -d. -f1)
ADDED=$(echo "$input" | jq -r '(.cost.total_lines_added // .changes.lines_added // .linesAdded // .additions // 0)')
REMOVED=$(echo "$input" | jq -r '(.cost.total_lines_removed // .changes.lines_removed // .linesRemoved // .deletions // 0)')
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)

WORK_DIR=$(echo "$input" | jq -r '.workspace.current_dir // .workingDirectory // .cwd // "."')
BRANCH=$(cd "$WORK_DIR" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")

# カラー定義
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"

# コンテキスト色
if [ "$USAGE_INT" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$USAGE_INT" -lt 80 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$RED"
fi

# コスト色
if [ "$COST_INT" -lt 1 ]; then
    COST_COLOR="$GREEN"
elif [ "$COST_INT" -lt 5 ]; then
    COST_COLOR="$YELLOW"
else
    COST_COLOR="$RED"
fi

# レート制限色（0-50%緑 / 50-80%黄 / 80%+赤）
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

printf "${CTX_COLOR}[%s]${RESET} Context: ${CTX_COLOR}%s%%${RESET} | ${COST_COLOR}\$%.2f${RESET} | ${CYAN}%s${RESET} | ${GREEN}+%s${RESET} ${RED}-%s${RESET}" \
    "$MODEL" "$USAGE_INT" "$COST" "$BRANCH" "$ADDED" "$REMOVED"
if [ -n "$LIMITS" ]; then
    printf " | ${LIMITS}"
fi
