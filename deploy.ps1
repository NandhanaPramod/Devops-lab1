# Deploy Hub VNet
Write-Host "Deploying Hub VNet..." -ForegroundColor Green
Set-Location -Path ".\hub-vnet"
terraform init
terraform plan -out hub.tfplan
Set-Location -Path ".."

# Deploy Spoke VNet
Write-Host "Deploying Spoke VNet..." -ForegroundColor Green
Set-Location -Path ".\spoke-vnet"
terraform init
terraform plan -out spoke.tfplan
Set-Location -Path ".."

# Deploy AKS Cluster
Write-Host "Deploying AKS Cluster..." -ForegroundColor Green
Set-Location -Path ".\aks-cluster"
terraform init
terraform plan -out aks.tfplan
Set-Location -Path ".."

Write-Host "Planning completed successfully! Review the .tfplan files before applying." -ForegroundColor Green 