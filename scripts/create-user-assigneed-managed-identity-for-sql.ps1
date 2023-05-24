param(
    [string]$resourceGroupName = "temp",
    [string]$managedIdentityName = "tester"
) 

$ErrorActionPreference = 'SilentlyContinue'

$managedIdentity = az identity show -g $resourceGroupName -n $managedIdentityName 2>&1 | ConvertFrom-Json

if($managedIdentity -eq $null)
{
    Write-Host "Creating managed identity $managedIdentityName"
    $managedIdentity = az identity create -g $resourceGroupName -n $managedIdentityName | ConvertFrom-Json
}

$graph = az ad sp list --filter "displayName eq 'Microsoft Graph'" | ConvertFrom-Json

$appRoleAssignmentUri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($managedIdentity.principalId)/appRoleAssignments"

$appRoles = @(
    "User.Read.All",
    "GroupMember.Read.All",
    "Application.Read.All"
)

foreach($appRole in $appRoles)
{
    $appRoleObject = $graph.appRoles | Where-Object {$_.value -eq $appRole}
    $body = @{
        principalId = $managedIdentity.principalId
        resourceId = $graph.id
        appRoleId = $appRoleObject.id
    }
    $bodyJson = $body | ConvertTo-Json -Compress -EscapeHandling EscapeHtml 
    $bodyJson = $bodyJson -replace '"', '\"'

    Write-Host "Assigning $appRole to $managedIdentityName"

    $result = az rest -m POST -u $appRoleAssignmentUri --headers "Content-Type=application/json" -b "$bodyJson" 2>&1
    Write-Host $result
}

exit 0