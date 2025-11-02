# Real Estate Analytics Platform

不動産取引データの分析プラットフォーム。BigQuery + dbt + Tableauによるエンドツーエンドのデータ分析基盤。

[![GitHub](https://img.shields.io/badge/GitHub-real--estate--analytics--dbt-blue)](https://github.com/ynom20/real-estate-analytics-dbt)

---

## 🎯 プロジェクト概要

### 目的
- データ分析×AI領域のスキルアップ
- エンドツーエンドの分析基盤構築
- 実務レベルの自動化実装

### 重視している点
1. **スキルアピール**: 実装技術の体系的整理とポートフォリオ活用
2. **体系的な整理**: 学んだことを構造化し、再利用可能な知識として蓄積

---

## 🏗️ アーキテクチャ
```
[データソース (CSV)]
        ↓
[手動アップロード]
        ↓
┌─────────────────────────────────┐
│  BigQuery (Data Warehouse)      │
│                                 │
│  Bronze Layer (生データ)         │
│         ↓                       │
│  [Cloud Functions + dbt]        │
│     (HTTPトリガー: 25秒)         │
│         ↓                       │
│  Silver Layer (クレンジング)     │
│         ↓                       │
│  Gold Layer (分析用)             │
│  - dim_addresses               │
│  - dim_dates                   │
│  - fct_transactions            │
└─────────────────────────────────┘
        ↓
   [Tableau]
```

---

## 💻 技術スタック

| レイヤー | 技術 | 役割 |
|---------|------|------|
| **データウェアハウス** | BigQuery | 生データ保管と高速クエリ |
| **変換処理** | dbt (Medallion) | Bronze→Silver→Gold変換 |
| **オーケストレーション** | Cloud Functions Gen2 | HTTP自動実行 |
| **可視化** | Tableau | ダッシュボード・BIレポート |
| **開発環境** | Python, PowerShell, Git | 開発・自動化・バージョン管理 |

---

## 🚀 セットアップ

### 前提条件

- Google Cloud Platform アカウント
- gcloud CLI インストール済み
- PowerShell 7.0以上
- dbt-core, dbt-bigquery インストール済み

### 初回セットアップ
```powershell
# リポジトリクローン
git clone https://github.com/ynom20/real-estate-analytics-dbt.git
cd real-estate-analytics-dbt

# GCP認証
gcloud auth login
gcloud config set project real-estate-project-2025

# dbt依存関係インストール（ローカル開発用）
cd dbt_project
dbt deps
```

---

## 📖 使い方

### ワークフロー1: dbtモデルの開発・デプロイ
```powershell
# 1. dbt_project/でSQLファイルを編集
code dbt_project/models/marts/fct_transactions.sql

# 2. 開発環境から本番環境へ同期 + デプロイ
.\deploy-dbt-function.ps1
# → 確認プロンプトで 'y' を入力

# 3. dbt実行テスト
.\run-dbt.ps1
# → 結果: 5モデル実行、約38秒
```

### ワークフロー2: データ更新時
```powershell
# 1. BigQueryに新データをアップロード（手動）
# BigQuery UI → テーブルアップロード

# 2. dbt変換実行
.\run-dbt.ps1

# 3. Tableauダッシュボードで確認
```

---

## 📁 プロジェクト構造
```
real-estate-analytics-dbt/
│
├── dbt_project/                    # dbt開発環境
│   ├── models/
│   │   ├── sources.yml            # Bronze層定義
│   │   ├── staging/               # Silver層
│   │   │   └── stg_transactions.sql
│   │   └── marts/                 # Gold層
│   │       ├── dim_addresses.sql
│   │       ├── dim_dates.sql
│   │       └── fct_transactions.sql
│   ├── macros/
│   │   ├── parse_time_to_minutes.sql
│   │   └── get_custom_schema.sql
│   └── dbt_project.yml
│
├── dbt-cloud-function/            # Cloud Functions本番環境
│   ├── main.py                    # エントリーポイント
│   ├── requirements.txt
│   ├── profiles/
│   │   └── profiles.yml           # BigQuery接続設定
│   └── dbt_project/               # 同期されたdbtプロジェクト
│
├── sync-dbt-project.ps1           # 同期スクリプト
├── deploy-dbt-function.ps1        # デプロイスクリプト
├── run-dbt.ps1                    # dbt実行スクリプト
│
└── README.md
```

---

## 🛠️ スクリプト詳細

### sync-dbt-project.ps1

**目的**: 開発環境のdbt_projectを本番環境へ同期
```powershell
.\sync-dbt-project.ps1
```

**処理内容**:
1. バックアップ作成
2. ファイルコピー
3. 不要ファイル削除（target, logs, .git）

**効果**: 手動コピー 5分 → 10秒

---

### deploy-dbt-function.ps1

**目的**: 同期 + 検証 + Cloud Functionsデプロイを一括実行
```powershell
.\deploy-dbt-function.ps1
```

**処理内容**:
1. `sync-dbt-project.ps1` 実行
2. 必須ファイル検証
3. 確認プロンプト
4. Cloud Functionsデプロイ

**デプロイ時間**: 2-3分

---

### run-dbt.ps1

**目的**: Cloud FunctionsのdbtをHTTPトリガーで実行
```powershell
.\run-dbt.ps1
```

**処理内容**:
1. HTTPリクエスト送信
2. 実行結果表示（JSON）
3. 実行時間計測

**実行時間**: 約38秒（5モデル）

---

## 🔍 データモデル

### Bronze Layer
```sql
-- real_estate_bronze.real_estate_raw
-- 生データ（取引データそのまま）
```

### Silver Layer
```sql
-- real_estate_silver.stg_transactions
-- クレンジング済み取引データ
SELECT
  CAST(REPLACE(trade_price, '¥', '') AS INT64) as price,
  PARSE_DATE('%Y年第%Q四半期', period) as transaction_date,
  ...
```

### Gold Layer

**ディメンション**:
```sql
-- dim_addresses: 住所マスタ（表記揺れ統一）
-- dim_dates: 日付ディメンション
```

**ファクト**:
```sql
-- fct_transactions: 分析用トランザクション
-- スタースキーマで最適化
```

---

## 📊 実装成果

### 定量的成果

| 項目 | 改善前 | 改善後 | 効果 |
|------|--------|--------|------|
| **同期作業** | 手動5分 | スクリプト10秒 | 96%削減 |
| **デプロイ** | 手動手順 | 1コマンド | 自動化 |
| **dbt実行** | 手動実行 | HTTPトリガー | 25秒で完了 |
| **運用コスト** | - | $0.02/月以下 | サーバーレス |

### 習得スキル

- ✅ サーバーレスアーキテクチャ設計
- ✅ dbtによるデータ変換パイプライン
- ✅ GCP IAM権限設計
- ✅ PowerShellによる自動化
- ✅ Git/GitHubのプロフェッショナル運用

---

## 🐛 トラブルシューティング

### スクリプト実行エラー

**エラー**: "スクリプトの実行が無効"
```powershell
# 実行ポリシー変更
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Cloud Functionsデプロイエラー

**エラー**: "API not enabled"
```bash
# 必要なAPIを有効化
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

---

### dbt実行エラー

**エラー**: "Database connection failed"
```yaml
# profiles.ymlの認証確認
# Cloud Functions環境では自動的にADCを使用
method: oauth  # これでOK
```

---

## 📚 関連リソース

### 公式ドキュメント
- [dbt Documentation](https://docs.getdbt.com/)
- [Google Cloud Functions](https://cloud.google.com/functions/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)

### プロジェクトリンク
- **GitHubリポジトリ**: https://github.com/ynom20/real-estate-analytics-dbt
- **Cloud Functions URL**: https://asia-northeast1-real-estate-project-2025.cloudfunctions.net/dbt-runner

---

## 🗺️ ロードマップ

### Phase 1: 基盤構築 ✅ 完了
- [x] メダリオンアーキテクチャ実装
- [x] Cloud Functions自動化
- [x] 開発ワークフロー確立

### Phase 2: 分析機能拡充 🚧 進行中
- [ ] データ品質テスト拡充
- [ ] 予測モデル追加（BigQuery ML）
- [ ] 異常値検知

### Phase 3: スコープ拡大 📋 計画中
- [ ] 他県データ追加
- [ ] 都道府県別比較分析
- [ ] 地理空間分析

---

## 👤 作成者

**Yu Nomura**

- GitHub: [@ynom20](https://github.com/ynom20)
- LinkedIn: [Yu Nomura](https://www.linkedin.com/in/yu-nomura)

---

## 📄 ライセンス

このプロジェクトは個人学習用です。

---

**最終更新**: 2025年11月2日