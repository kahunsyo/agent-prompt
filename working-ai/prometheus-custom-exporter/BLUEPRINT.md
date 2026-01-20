# Prometheusカスタムエクスポータのサンプルプロジェクト

## 概要
Goで実装したPrometheusカスタムエクスポータの実用例。アプリケーション固有のメトリクスを収集し、Prometheus形式で公開する方法を示します。

## 背景
Prometheusは強力な監視システムですが、標準のエクスポータでは対応できない独自のメトリクス収集が必要になることがあります。例えば:
- ビジネスロジック固有のメトリクス（注文数、課金額など）
- カスタムアプリケーションの内部状態
- 既存システムからのメトリクス取得（API経由など）

このような場合、カスタムエクスポータを実装する必要があります。

## 目標
Goを使ってPrometheusカスタムエクスポータを実装し、以下を実現する:
- Prometheus公式クライアントライブラリ(`prometheus/client_golang`)を使用
- 複数種類のメトリクスタイプ（Counter, Gauge, Histogram）の実装例
- Docker ComposeでエクスポータとPrometheusを同時起動
- Prometheusのダッシュボードでメトリクスを確認

## 要件

### 機能要件
1. **メトリクスの種類**
   - Counter: リクエスト総数など、増加のみするメトリクス
   - Gauge: 現在の接続数など、増減するメトリクス
   - Histogram: レスポンスタイムなど、分布を記録するメトリクス

2. **エクスポータ機能**
   - `/metrics`エンドポイントでPrometheus形式のメトリクスを公開
   - メトリクスラベルの適切な使用（例: `{method="GET", status="200"}`）
   - ヘルスチェック用の`/health`エンドポイント

3. **シミュレーション機能**
   - 実際のアプリケーションを模したメトリクス生成
   - バックグラウンドでメトリクスを定期的に更新
   - ランダムな値を使って現実的なメトリクスを生成

### 技術要件
1. **Go実装**
   - Go 1.21以上
   - `prometheus/client_golang` v1.19以上
   - 標準ライブラリを活用したシンプルな実装

2. **コンテナ化**
   - Dockerfile: マルチステージビルドで最適化
   - docker-compose.yml: エクスポータとPrometheusを統合

3. **Prometheus設定**
   - スクレイプ設定（10秒間隔）
   - エクスポータの自動検出
   - Webブラウザでアクセス可能（ポート9090）

### ドキュメント要件
1. **README.md**
   - 前提条件（Docker, Docker Compose）
   - セットアップ手順（クローン、ビルド、起動）
   - アクセス方法（エクスポータ、Prometheus UI）
   - メトリクスの確認方法（クエリ例）
   - カスタマイズ方法（新しいメトリクスの追加）
   - トラブルシューティング

2. **コードコメント**
   - 各メトリクスタイプの説明
   - 実装パターンの解説
   - ベストプラクティスの提示

## 期待される成果物

```
working-ai/prometheus-custom-exporter/artifact/
├── README.md                    # 詳細なセットアップガイド
├── main.go                      # エクスポータのメインコード
├── go.mod                       # Go モジュール定義
├── go.sum                       # 依存関係のチェックサム
├── Dockerfile                   # コンテナイメージ定義
├── docker-compose.yml           # エクスポータ + Prometheus 構成
└── prometheus.yml               # Prometheus設定ファイル
```

## 検証方法
1. `docker-compose up`でサービス起動
2. エクスポータが`http://localhost:8080/metrics`でメトリクスを公開
3. Prometheusが`http://localhost:9090`でアクセス可能
4. Prometheusダッシュボードでメトリクスをクエリして可視化
5. エクスポータのメトリクスがPrometheusに正しくスクレイプされている

## 参考情報
- Prometheus公式ドキュメント: https://prometheus.io/docs/introduction/overview/
- Writing Exporters: https://prometheus.io/docs/instrumenting/writing_exporters/
- Go client library: https://github.com/prometheus/client_golang
