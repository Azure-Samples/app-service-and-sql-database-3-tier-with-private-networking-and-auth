param(
    [string]$prefix = "dotnet-vbd",
    [string]$location = "UK South",
    [switch]$deleteOnly
) 

$resourceGroupNames = @(
    "$prefix-module2",
    "$prefix-module3",
    "$prefix-module4",
    "$prefix-module5",
    "$prefix-module6-dev",
    "$prefix-module6-test",
    "$prefix-module6-prod"
)

foreach($resourceGroupName in $resourceGroupNames)
{
    $exists = az group exists --name $resourceGroupName | ConvertFrom-Json
    if($exists)
    {
        Write-Host "Deleting resource group $resourceGroupName"
        az group delete --name $resourceGroupName --yes
    }

    if(!($deleteOnly))
    {
        Write-Host "Creating resource group $resourceGroupName"
        az group create --name $resourceGroupName --location $location
    }
}