param(
    [string]$apiAppAuthRegistrationName = "test-api-app-auth",
    [string]$webAppAuthRegistrationName = "test-web-app-auth",
    [string]$apiAppRedirectUri = "https://test-api-app.azurewebsites.net/.auth/login/aad/callback",
    [string]$webAppRedirectUri = "https://test-web-app.azurewebsites.net/.auth/login/aad/callback",
    [string]$webAppUser = "jaredholgate@microsoft.com"
) 

$ErrorActionPreference = 'SilentlyContinue'

$appRegistrationNames = @(
    @{
        Key = "web-app"
        Name = $webAppAuthRegistrationName
        RedirectUri = $webAppRedirectUri
    },
    @{
        Key = "api-app"
        Name = $apiAppAuthRegistrationName
        RedirectUri = $apiAppRedirectUri
    }
)

foreach($appRegistrationName in $appRegistrationNames)
{
    $appRegistrations = az ad app list --display-name $appRegistrationName.Name | ConvertFrom-Json

    if($appRegistrations.Length -eq 0)
    {
        Write-Host "Creating app registration $($appRegistrationName.Name) for redirect uri $($appRegistrationName.RedirectUri)"
        
        # Create the app registration
        $appRegistration = az ad app create --display-name $appRegistrationName.Name --sign-in-audience AzureADMyOrg --enable-access-token-issuance true --enable-id-token-issuance true --web-redirect-uris $appRegistrationName.RedirectUri  | ConvertFrom-Json
        
        # Add the identifier uri
        $updateResult = az ad app update --id $appRegistration.id --identifier-uris "api://$($appRegistration.appId)"  | ConvertFrom-Json
        
        # Add the default user_impersonation scope
        $apiScopeId = [guid]::NewGuid().Guid
        $apiScopeJson = @{
            requestedAccessTokenVersion = 2
            oauth2PermissionScopes      = @(
                @{
                    adminConsentDescription = "Allow the application to access on behalf of the signed-in user."
                    adminConsentDisplayName = "Access"
                    id                      = "$apiScopeId"
                    isEnabled               = $true
                    type                    = "User"
                    userConsentDescription  = "Allow the application to access on your behalf."
                    userConsentDisplayName  = "Access"
                    value                   = "user_impersonation"
                }
            )
        } | ConvertTo-Json -d 4 -Compress
        $apiUpdateBody = $apiScopeJson | ConvertTo-Json -d 4
        $updateResult = az ad app update --id $appRegistration.id --set api=$apiUpdateBody | ConvertFrom-Json

        # Add the API User.Read delegated permission
        az ad app permission add --id $appRegistration.id --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

        # Create the Service Principal for the app registration
        $servicePrincipal = az ad sp create --id $appRegistration.id | ConvertFrom-Json

        # Set the Service Principal to require app role assignment
        $updateResult = az ad sp update --id $servicePrincipal.id --set appRoleAssignmentRequired=true

        # Add the app role to the app registration for the API app
        if($appRegistrationName.Name -eq $apiAppAuthRegistrationName)
        {
            Write-Host "Updating app registration $($appRegistrationName.Name) with app roles"
            $appRoles = @(
                @{
                    allowedMemberTypes = @( "Application" )
                    description        = "Allow the application to access to api on behalf of the managed identity."
                    displayName        = "Access API"
                    isEnabled          = $true
                    value              = "Api.Read.Write"
                }
                
            ) | ConvertTo-Json -AsArray -d 4 -Compress
    
            $appRolesBody = $appRoles | ConvertTo-Json -d 4
            $updateResult = az ad app update --id $appRegistration.id --app-roles $appRolesBody 2>&1  | ConvertFrom-Json
        }

        # Add users to the UI App registration
        if($appRegistrationName.Name -eq $webAppAuthRegistrationName)
        {
            $ErrorActionPreference = 'SilentlyContinue'

            $user = az ad user list --filter "mail eq '$webAppUser'" 2>&1 | ConvertFrom-Json

            $appRoleAssignmentUri = "https://graph.microsoft.com/v1.0/users/$($user.id)/appRoleAssignments"

            $body = @{
                principalId = $user.id
                resourceId = $servicePrincipal.id
                appRoleId = "00000000-0000-0000-0000-000000000000" # Default App Role
            }
            $bodyJson = $body | ConvertTo-Json -Compress -EscapeHandling EscapeHtml 
            $bodyJson = $bodyJson -replace '"', '\"'

            Write-Host "Assigning Default Role to $webAppUser"

            $result = az rest -m POST -u $appRoleAssignmentUri --headers "Content-Type=application/json" -b "$bodyJson" 2>&1
        }
    }
    else 
    {
        $appRegistration = $appRegistrations[0]
    }

    # Get the secret for the app registration
    $secret = az ad app credential reset --id $appRegistration.id --append --display-name "EasyAuth" | ConvertFrom-Json
    Write-Host "##vso[task.setvariable variable=$($appRegistrationName.Key)-clientId;]$($appRegistration.appId)"
    Write-Host "##vso[task.setvariable variable=$($appRegistrationName.Key)-password;issecret=true]$($secret.password)"
}

exit 0