# deploy-dbt-function.ps1
# dbt-cloud-functionをGCPにデプロイ

Write-Host "🚀 Cloud Functionsへデプロイ中..." -ForegroundColor Cyan

# 本番環境ディレクトリに移動
Set-Location ./dbt-cloud-function

# デプロイ実行
gcloud functions deploy dbt-runner `
  --gen2 `
  --runtime python311 `
  --trigger-http `
  --allow-unauthenticated `
  --entry-point run_dbt `
  --timeout 540s `
  --memory 1GB `
  --region asia-northeast1 `
  --source .

# 元のディレクトリに戻る
Set-Location ..

Write-Host "✅ デプロイ完了" -ForegroundColor Green
Write-Host "🌐 URL: https://asia-northeast1-real-estate-project-2025.cloudfunctions.net/dbt-runner" -ForegroundColor Blue