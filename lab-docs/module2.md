# Module 2 - API Development with SQL Backend

## Objectives
- Create a REST API project in ASP.NET Core with .NET 7.0
- Support CRUD operations on Products
    - Products should have Id, Name, Description and Category
- Use Entity Framework to build schema and connect to SQL Server database
- Use built in dependency injection capabilities
- Use Azure DevOps  YAML pipelines to deploy the code and seed the database
- Stretch goal - Run an integration test as part of the pipeline

## Azure CLI Steps
1. Create resource groups using the `create-resource-groups.ps1` script.

## Bicep IaC Steps
1. Create an App Service Plan
1. Create an App Service
1. Create a SQL Server with SQL Authentication
1. Create a SQL Database
1. Enable Public Access to the SQL Server for Azure Service. Hint: 0.0.0.0
1. Add the SQL Database Connection String with SQL Authentication to the App Service

## Bicep IaC Continuous Delivery with Azure DevOps YAML Pipelines Steps
1. Create a Service Connection called `dotnet-vbd-sc` and associated Service Principal with permission to deploy to your resource group
1. Create a new YAML pipeline. Hint - Use the Azure DevOps web interface to get intellisense
1. Run on an ubuntu agent
1. Use your Service Connection to deploy the Bicep to Azure

## ASP.NET Core C# API Steps
1. Create a new ASP.NET Core Web API Project
    1. Use .NET 7.0
    1. No authentication
    1. Use controllers
    1. Enable OpenAPI
1. Remove the scaffolded controller and model
1. Create a new controller with Create, Read, Update, Delete and List operations leveraging a DbContext. Hint - Use 'New Scaffolded Item...'.
1. Create seed data for your products. Hint - Override OnModelCreating
1. Create a DB migration and update your localdb instance. Hint - Double click on 'Connected Services'.
1. Optional: Create a unit and integration test using EF InMemory and run it.
1. Debug the site locally and test using the OpenAPI endpoint.

For further hints, look at [this](https://devblogs.microsoft.com/visualstudio/web-api-development-in-visual-studio-2022) article.

## API App Continuous Integration with Azure DevOps YAML Pipelines Steps
1. Create a new YAML pipeline. Hint - Use the Azure DevOps web interface to get intellisense
1. Run on an ubuntu agent
1. Create restore, build and publish steps, ensuring to use the Release configuration
1. Create an idempotent SQL script from Entity Framework migrations. Hint: [See this link](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/applying?tabs=dotnet-core-cli#idempotent-sql-scripts)
1. Publish the code as a pipeline artifact 
1. Run the pipeline

## API App Continuous Delivery with Azure DevOps YAML Pipelines Steps
1. Create a new stage for deploying to dev.
1. Create a deployment job for the database
1. Deploy the database schema and seed data
1. Create a deployment job for the app
1. Deploy the code to the app service using a service connection

## Module Completion Criteria
1. Show your coach the ability to list, add and update a product via the OpenAPI UI with your App deployed to Azure
1. Show your coach the output of both Azure DevOps Pipelines