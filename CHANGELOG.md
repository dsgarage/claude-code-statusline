# Changelog

## [3.0.0] - 2026-06-06

### 🚀 新機能
- Claude Code の最新APIレスポンス形式に完全対応
- より多くのJSONパスパターンをサポート

### 🔧 改善点  
- APIレスポンスの検出をより柔軟に（キャメルケース、スネークケース両対応）
- モデル名検出の大文字小文字両対応
- 以下の追加フィールドパスをサポート:
  - モデル: `modelName`
  - コンテキスト: `contextUsage.percentage`, `usage.percentage`
  - コスト: `totalCost`, `cost`
  - コード変更: `linesAdded`, `linesRemoved`, `additions`, `deletions`
  - ワークディレクトリ: `workingDirectory`, `cwd`
  - トークン: `tokens.input`, `inputTokens`, `tokens.output`, `outputTokens`
  - キャッシュ: `tokens.cacheCreation`, `cacheCreationTokens`, `tokens.cacheRead`, `cacheReadTokens`

### 📝 ドキュメント
- インストーラーをv3.0に更新
- 各スクリプトのバージョンをv3.0に更新

## [2.0.0] - 2024-06-05

### 🚀 新機能
- Claude Code の最新バージョンに対応
- 複数の JSON フィールドパスに対応（後方互換性を保持）
- より堅牢なエラーハンドリング

### 🔧 改善点
- モデル名の検出ロジックを改善（opus/sonnet/haiku を正確に識別）
- API エンドポイントとヘッダーを最新版に更新
- レート制限情報の取得を複数のフィールド名に対応
- キャッシュの有効性チェックを強化

### 🐛 修正
- 新しい Claude Code バージョンでステータスラインが表示されない問題を修正
- トークン取得失敗時のフォールバック処理を追加
- stat コマンドの互換性問題を修正（macOS/Linux 両対応）

### 📝 ドキュメント
- README に v2.0 対応を明記
- 各スクリプトにバージョン番号を追加

### 🔄 互換性
- 古い JSON 形式と新しい JSON 形式の両方に対応
- 以下のフィールドパスをサポート:
  - モデル: `model.display_name`, `model.name`, `model`
  - コンテキスト: `context_window.used_percentage`, `context.used_percentage`
  - コスト: `cost.total_cost_usd`, `costs.total`
  - コード変更: `cost.total_lines_added/removed`, `changes.lines_added/removed`
  - レート制限: `five_hour`, `5_hour`, `rate_limits.five_hour`

## [1.0.0] - 2024-05-30

### 初回リリース
- 12種類のステータスラインスクリプトを公開
- インストール/アンインストールスクリプト付属
- カラー表示、プログレスバー、Git 統合などの機能を提供