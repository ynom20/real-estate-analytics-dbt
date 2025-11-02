# deploy-dbt-function.ps1
# Deploy dbt project to Cloud Functions

# Configuration
$ProjectId = "real-estate-project-2025"
$FunctionName = "dbt-runner"
$Region = "asia-northeast1"
$SourceDir = "./dbt-cloud-function"

Write-Host "`n=== Deploy dbt Cloud Function ===" -ForegroundColor Cyan

# Step 1: Sync dbt_project
Write-Host "`nStep 1: Syncing dbt_project..." -ForegroundColor Yellow
.\sync-dbt-project.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Sync failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Validate required files
Write-Host "`nStep 2: Validating files..." -ForegroundColor Yellow

$RequiredFiles = @(
    "$SourceDir/main.py",
    "$SourceDir/requirements.txt",
    "$SourceDir/profiles/profiles.yml",
    "$SourceDir/dbt_project/dbt_project.yml"
)

$allValid = $true
foreach ($file in $RequiredFiles) {
    if (Test-Path $file) {
        Write-Host "  OK: $file" -ForegroundColor Green
    } else {
        Write-Host "  Missing: $file" -ForegroundColor Red
        $allValid = $false
    }
}

if (-not $allValid) {
    Write-Host "`nValidation failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Confirm deployment
Write-Host "`nStep 3: Ready to deploy" -ForegroundColor Yellow
Write-Host "  Project: $ProjectId"
Write-Host "  Function: $FunctionName"
Write-Host "  Region: $Region"
$confirmation = Read-Host "`nProceed with deployment? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

# Step 4: Deploy
Write-Host "`nStep 4: Deploying to Cloud Functions..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes...`n" -ForegroundColor Gray

gcloud functions deploy $FunctionName `
    --gen2 `
    --runtime python311 `
    --trigger-http `
    --allow-unauthenticated `
    --entry-point run_dbt `
    --timeout 540s `
    --memory 1GB `
    --region $Region `
    --source $SourceDir `
    --project $ProjectId

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nDeployment successful!" -ForegroundColor Green
    $functionUrl = "https://$Region-$ProjectId.cloudfunctions.net/$FunctionName"
    Write-Host "`nFunction URL:" -ForegroundColor Cyan
    Write-Host "  $functionUrl" -ForegroundColor White
    
    Write-Host "`nTest the function:" -ForegroundColor Cyan
    Write-Host "  curl -X POST $functionUrl" -ForegroundColor Gray
} else {
    Write-Host "`nDeployment failed!" -ForegroundColor Red
    exit 1
}