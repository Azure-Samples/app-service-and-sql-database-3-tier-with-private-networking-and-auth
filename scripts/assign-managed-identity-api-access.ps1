param(
    [string]$managedIdentityName = "test-web-app",
    [string]$appRegistrationName = "test-api-app-auth",
    [string]$appRoleName = "Api.Read.Write"
) 

$ErrorActionPreference = 'SilentlyContinue'

$managedIdentity = az ad sp list --filter "displayName eq '$managedIdentityName'" 2>&1 | ConvertFrom-Json

$graph = az ad sp list --filter "displayName eq '$appRegistrationName'" | ConvertFrom-Json

$appRoleAssignmentUri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($managedIdentity.id)/appRoleAssignments"

$appRoles = @(
    $appRoleName
)

foreach($appRole in $appRoles)
{
    $appRoleObject = $graph.appRoles | Where-Object {$_.value -eq $appRole}
    $body = @{
        principalId = $managedIdentity.id
        resourceId = $graph.id
        appRoleId = $appRoleObject.id
    }
    $bodyJson = $body | ConvertTo-Json -Compress -EscapeHandling EscapeHtml 
    $bodyJson = $bodyJson -replace '"', '\"'

    Write-Host "Assigning $appRole to $managedIdentityName"

    $result = az rest -m POST -u $appRoleAssignmentUri --headers "Content-Type=application/json" -b "$bodyJson" 2>&1
}

exit 0