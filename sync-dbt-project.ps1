# sync-dbt-project.ps1
# 開発環境から本番環境へdbtプロジェクトを同期

Write-Host "🔄 dbtプロジェクトを同期中..." -ForegroundColor Cyan

# 既存の本番環境dbtプロジェクトを削除
Remove-Item -Recurse -Force ./dbt-cloud-function/dbt_project -ErrorAction SilentlyContinue

# 開発環境からコピー
Copy-Item -Recurse ./dbt_project ./dbt-cloud-function/dbt_project

# 不要なファイルを削除
Remove-Item -Recurse -Force ./dbt-cloud-function/dbt_project/target -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ./dbt-cloud-function/dbt_project/logs -ErrorAction SilentlyContinue
Remove-Item -Force ./dbt-cloud-function/dbt_project/.gitignore -ErrorAction SilentlyContinue

Write-Host "✅ 同期完了" -ForegroundColor Green