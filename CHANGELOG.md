# Changelog

## 2025-11-02: データ期間拡張（2025年Q2追加）

### 変更内容
- 2025年Q2の不動産取引データを追加
- データ期間: 2005年Q3-2025年Q1 → 2005年Q3-2025年Q2

### 実施内容
- BigQuery CSV upload via bq load command
- Source: 国土交通省 不動産情報ライブラリ
- 追加レコード数: 11,925

### 検証
- dbt run: 成功
- dbt test: 全てパス
- transaction_id uniqueness: 確認済み
- 四半期別データ分布: 正常
