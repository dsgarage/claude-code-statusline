#!/bin/bash
# Claude Code Statusline - アンインストーラー
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

echo ""
echo "=== Claude Code Statusline アンインストール ==="
echo ""

# statusline.sh 削除
if [ -f "$CLAUDE_DIR/statusline.sh" ]; then
    rm "$CLAUDE_DIR/statusline.sh"
    echo "  削除: $CLAUDE_DIR/statusline.sh"
else
    echo "  statusline.sh は見つかりません（スキップ）"
fi

# settings.json から statusLine を削除
if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
    if jq -e '.statusLine' "$SETTINGS" &>/dev/null; then
        TMP=$(mktemp)
        jq 'del(.statusLine)' "$SETTINGS" > "$TMP"
        mv "$TMP" "$SETTINGS"
        echo "  設定: $SETTINGS から statusLine を削除"
    fi
fi

echo ""
echo "=== アンインストール完了 ==="
echo "Claude Code を再起動するとステータスラインが非表示になります。"
