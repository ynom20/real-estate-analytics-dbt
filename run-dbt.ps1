# run-dbt.ps1
# Execute dbt via Cloud Functions

$FunctionUrl = "https://asia-northeast1-real-estate-project-2025.cloudfunctions.net/dbt-runner"

Write-Host "`nExecuting dbt..." -ForegroundColor Cyan
Write-Host "URL: $FunctionUrl`n" -ForegroundColor Gray

$startTime = Get-Date

try {
    $response = Invoke-RestMethod -Uri $FunctionUrl -Method Post
    $duration = (Get-Date) - $startTime
    
    Write-Host "Completed in $([math]::Round($duration.TotalSeconds, 1)) seconds`n" -ForegroundColor Green
    
    Write-Host "Result:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 5
    
} catch {
    Write-Host "Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    exit 1
}