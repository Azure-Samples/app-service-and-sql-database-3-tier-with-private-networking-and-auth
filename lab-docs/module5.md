# Module 5 - Authentication

## Objectives
1. The SQL Database only implements AzureAD authentication, SQL Authentication is disabled.
1. The API App Service implements AzureAD authentication with an App Role and the Web App must authenticate.
1. The UI App Service implements AzureAD authentication and users are redirected to sign in.

## IaC Pipeline Update Steps
1. Create a User Assigned Managed Identity for the SQL Server that has the permissions required for assigning AzureAD users to the Database. Hint: Run before Bicep
1. Create App Registrations for the API and Web Apps and create an App Role for the API App. Hint Run before the Bicep
1. Create Associated Service Principals for the App Registrations and Restrict Access to Principals Assigned to App Roles
1. Assign your own account to the Default App Role for the Web App. Hint: 00000000-0000-0000-0000-000000000000
1. Grant Access to the API App Role for the Web App Managed Identity. Hint: Run after the Bicep

## Bicep IaC Steps
1. Update the API and Web App Services to implement AzureAD authentication using the App Registrations created in the pipeline.
1. Update SQL Server to turn off SQL Authentication and turn on AzureAD Authentication, setting the deployment Service Principal as the Application owner.
1. Update the Connection String of the API App Service to use the Managed Identity
1. Add an App Setting to the UI App, so it knows the Uri of the API App Registration
1. Run the pipeline to apply the changes

## API Pipeline Update Steps
1. Update the connection string used by the database update steps and leverage a token from the Service Principal to perform the database update and seeding steps.
1. Grant the App Service Managed Identity Read / Write permissions on the database.

## Web App Code Update Steps
1. Use the managed identity of the Web App to connect to the API. Hint: Use Microsoft.Identity
1. Add code to show the logged in user by querying the authentication headers from the App Service
1. Add a log out button.

## Module Completion Criteria
1. Show your coach being prompted for authentication for the Web App.
1. Show your coach the ability to list, add and update a product via the Web UI from your App deployed to Azure
1. Show your coach the configuration of the SQL Server to prove SQL Auth is disabled.
1. Show your coach the configuration of the API App Service to provide that Authentication is enabled.
1. Show your coach the output of all three Azure DevOps Pipelines