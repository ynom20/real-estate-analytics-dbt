# run-dbt.ps1
# Cloud Functionsでdbtを実行

Write-Host "▶️ dbt run実行中..." -ForegroundColor Cyan

$url = "https://asia-northeast1-real-estate-project-2025.cloudfunctions.net/dbt-runner"

try {
    $response = Invoke-RestMethod -Uri $url -Method POST -ContentType "application/json"
    
    Write-Host "✅ 実行完了" -ForegroundColor Green
    Write-Host "Status: $($response.status)" -ForegroundColor Yellow
    Write-Host "Duration: $($response.duration_seconds) seconds" -ForegroundColor Yellow
    
    # 標準出力を表示
    Write-Host "`n--- dbt output ---" -ForegroundColor Cyan
    Write-Host $response.stdout
    
} catch {
    Write-Host "❌ 実行失敗" -ForegroundColor Red
    Write-Host $_.Exception.Message
}