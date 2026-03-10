# Claude Code Statusline Collection

Claude Code のステータスラインスクリプト集。コンテキスト使用率、コスト、Git ステータス、トークン消費量などをリアルタイム表示します。

## スクリプト一覧

| スクリプト | 表示例 | 説明 |
|-----------|--------|------|
| `minimal` | `Context: 45%` | コンテキスト使用率のみ |
| `standard` | `[Opus] Context: 45% \| $0.12` | モデル + コンテキスト + コスト |
| `standard-color` | `[Opus] Context: 45% \| $0.12` | 上記のカラー版（使用率で色分け） |
| `full` | `[Opus] Context: 45% \| $0.12 \| main \| +245 -89` | 全部入り |
| `full-color` | 同上 | 全部入りカラー版 |
| `progress-bar` | `[Opus] [████████░░░░░░░░░░░░] 45% \| $0.12` | プログレスバー |
| `git-focused` | `main \| M:3 U:1 S:2 \| Context: 45%` | Git 情報重視 |
| `cost-tracker` | `$0.12 \| In:65K Out:12K Cache:20K \| Context: 45%` | コスト追跡重視 |
| `tokens-detail` | `[Opus] In:65K Create:15K Read:5K Out:12K (48%) \| $0.12` | トークン内訳詳細 |
| `multiline` | 2行: Git + プログレスバー | 2行表示 |
| `compact` | `Op\|45%\|$0.12` | 最小幅（狭いターミナル向け） |

### カラー表示の色分けルール

**コンテキスト使用率:**
- 0-49%: 緑（余裕あり）
- 50-79%: 黄（注意）
- 80%+: 赤（残り少ない）

**コスト:**
- $1 未満: 緑
- $1-5: 黄
- $5+: 赤

## クイックセットアップ

### ワンライナーインストール

```bash
git clone https://github.com/dsgarage/claude-code-statusline.git /tmp/claude-code-statusline \
  && /tmp/claude-code-statusline/install.sh \
  && rm -rf /tmp/claude-code-statusline
```

### 手動インストール

```bash
git clone https://github.com/dsgarage/claude-code-statusline.git
cd claude-code-statusline
./install.sh
```

対話形式でスクリプトを選択できます。

### 手動で直接コピーする場合

```bash
# 好みのスクリプトを ~/.claude/statusline.sh にコピー
cp scripts/standard-color.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

`~/.claude/settings.json` に以下を追加：

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Claude Code を再起動すると反映されます。

## 前提条件

- **Claude Code** がインストール済み
- **jq** がインストール済み（`brew install jq`）

## 利用可能なデータフィールド

ステータスラインスクリプトは、stdin から JSON データを受け取ります。

### コンテキストウィンドウ

| フィールド | 型 | 説明 |
|-----------|---|------|
| `context_window.size` | number | ウィンドウサイズ（トークン数） |
| `context_window.used_percentage` | number | 使用率（0-100） |
| `context_window.input_tokens` | number | 入力トークン数 |
| `context_window.output_tokens` | number | 出力トークン数 |
| `context_window.cache_creation_tokens` | number | キャッシュ作成トークン |
| `context_window.cache_read_tokens` | number | キャッシュ読み取りトークン |

### コスト

| フィールド | 型 | 説明 |
|-----------|---|------|
| `cost.total_cost_usd` | number | セッション累計コスト（USD） |
| `cost.total_lines_added` | number | 追加行数 |
| `cost.total_lines_removed` | number | 削除行数 |

### モデル

| フィールド | 型 | 説明 |
|-----------|---|------|
| `model.display_name` | string | 表示名（`"Opus"`, `"Sonnet"` 等） |
| `model.id` | string | モデル ID |

### ワークスペース

| フィールド | 型 | 説明 |
|-----------|---|------|
| `workspace.current_dir` | string | 現在の作業ディレクトリ |

### JSON 例

```json
{
  "model": {
    "id": "claude-opus-4-6",
    "display_name": "Opus"
  },
  "workspace": {
    "current_dir": "/Users/user/project"
  },
  "context_window": {
    "size": 200000,
    "input_tokens": 65000,
    "cache_creation_tokens": 15000,
    "cache_read_tokens": 5000,
    "output_tokens": 12000,
    "used_percentage": 48.5
  },
  "cost": {
    "total_cost_usd": 0.1234,
    "total_lines_added": 245,
    "total_lines_removed": 89
  }
}
```

## カスタマイズ

### 自作スクリプトの作り方

`~/.claude/statusline.sh` を直接編集するか、新しいスクリプトを作成します：

```bash
#!/bin/bash
input=$(cat)

# jq でフィールドを取得
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# ANSI カラーコードが使用可能
GREEN="\033[32m"
RESET="\033[0m"

# stdout に出力 → ステータスラインに表示
printf "${GREEN}[%s]${RESET} %s%% | \$%.2f" "$MODEL" "$USAGE" "$COST"
```

### ポイント

- `cat` で stdin を読み込む（JSON データ）
- `jq` でフィールドを取得（`// "default"` でデフォルト値指定）
- ANSI カラーコード対応（`\033[XXm`）
- 複数行出力で複数行表示
- 処理は軽量に（更新頻度が高いため）

## アンインストール

```bash
./uninstall.sh
```

または手動で：

```bash
rm ~/.claude/statusline.sh
# settings.json から statusLine を削除
```

## ファイル構成

```
claude-code-statusline/
├── README.md
├── LICENSE
├── install.sh              ← 対話式インストーラー
├── uninstall.sh            ← アンインストーラー
├── scripts/
│   ├── minimal.sh          ← コンテキスト使用率のみ
│   ├── standard.sh         ← モデル + コンテキスト + コスト
│   ├── standard-color.sh   ← 上記カラー版
│   ├── full.sh             ← 全部入り
│   ├── full-color.sh       ← 全部入りカラー版
│   ├── progress-bar.sh     ← プログレスバー表示
│   ├── git-focused.sh      ← Git 情報重視
│   ├── cost-tracker.sh     ← コスト追跡重視
│   ├── tokens-detail.sh    ← トークン内訳詳細
│   ├── multiline.sh        ← 2行表示
│   └── compact.sh          ← 最小幅コンパクト
└── .gitignore
```

## ライセンス

MIT
