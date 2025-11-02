Write-Host "Starting sync..." -ForegroundColor Cyan

Copy-Item -Recurse -Force ./dbt_project ./dbt-cloud-function/

Remove-Item -Recurse -Force ./dbt-cloud-function/dbt_project/target -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ./dbt-cloud-function/dbt_project/.git -ErrorAction SilentlyContinue

Write-Host "Done!" -ForegroundColor Green