#!/bin/bash
# Claude Code Statusline - インストーラー
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

echo ""
echo "=== Claude Code Statusline インストーラー ==="
echo ""

# jq チェック
if ! command -v jq &>/dev/null; then
    echo "エラー: jq がインストールされていません"
    echo "  brew install jq"
    exit 1
fi

# スクリプト一覧表示
echo "利用可能なスクリプト:"
echo ""
echo "  1) minimal        - コンテキスト使用率のみ"
echo "  2) standard       - モデル + コンテキスト + コスト"
echo "  3) standard-color - モデル + コンテキスト（色分け） + コスト"
echo "  4) full           - 全部入り（Git + コード変更量含む）"
echo "  5) full-color     - 全部入りカラー版"
echo "  6) progress-bar   - プログレスバー表示"
echo "  7) git-focused    - Git 情報重視"
echo "  8) cost-tracker   - コスト追跡重視"
echo "  9) tokens-detail  - トークン消費の内訳詳細"
echo "  10) multiline     - 2行表示（Git + プログレスバー）"
echo "  11) compact       - 最小幅コンパクト（狭いターミナル向け）"
echo ""
read -p "番号を選択 [3]: " CHOICE
CHOICE=${CHOICE:-3}

case "$CHOICE" in
    1)  SCRIPT="minimal.sh" ;;
    2)  SCRIPT="standard.sh" ;;
    3)  SCRIPT="standard-color.sh" ;;
    4)  SCRIPT="full.sh" ;;
    5)  SCRIPT="full-color.sh" ;;
    6)  SCRIPT="progress-bar.sh" ;;
    7)  SCRIPT="git-focused.sh" ;;
    8)  SCRIPT="cost-tracker.sh" ;;
    9)  SCRIPT="tokens-detail.sh" ;;
    10) SCRIPT="multiline.sh" ;;
    11) SCRIPT="compact.sh" ;;
    *)  echo "無効な選択です"; exit 1 ;;
esac

echo ""
echo "選択: $SCRIPT"

# ~/.claude ディレクトリ作成
mkdir -p "$CLAUDE_DIR"

# スクリプトをコピー
cp "$SCRIPT_DIR/scripts/$SCRIPT" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"
echo "  コピー: $CLAUDE_DIR/statusline.sh"

# settings.json に statusLine 設定を追加
if [ -f "$SETTINGS" ]; then
    # 既存の settings.json に statusLine を追加/更新
    BACKUP="$SETTINGS.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS" "$BACKUP"
    echo "  バックアップ: $BACKUP"

    # jq で statusLine を追加
    TMP=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS" > "$TMP"
    mv "$TMP" "$SETTINGS"
else
    # 新規作成
    echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' | jq . > "$SETTINGS"
fi
echo "  設定: $SETTINGS に statusLine を追加"

echo ""
echo "=== インストール完了 ==="
echo ""
echo "Claude Code を再起動すると、ステータスラインが表示されます。"
echo "スクリプトを変更したい場合は再度 ./install.sh を実行してください。"
