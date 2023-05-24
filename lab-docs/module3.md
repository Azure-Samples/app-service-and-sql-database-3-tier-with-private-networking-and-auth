# Module 3 - UI Development with API Backend

## Objectives
- Create a Web App project in ASP.NET Core with .NET 7.0
- Support CRUD operations and List for Products in the API
- Use a Service and Interface with built in dependency injection capabilities
- Use Azure DevOps YAML pipelines to deploy the code

## Bicep IaC Steps
1. Create an App Service and Assign to the existing App Service Plan
1. Add an App Setting with the Uri of the API App Service
1. Run your Pipeline to deploy the changes

## ASP.NET Core C# API Steps
1. Create a new ASP.NET Core Web App Project
    1. Use .NET 7.0
    1. No authentication
    1. Use Razor Pages
1. Create a new Service class that leverages HttpClient to call the API.
1. Create an interface for the Service class and setup dependency injection, passing in the Api Uri from an environment variable.
1. Create a new razor page with a List of Products.
1. Create a new razor page with Create, Update and Delete capabilities.
1. Debug the site locally, while pointing to your API debugging in another VS instance.

## API App Continuous Integration with Azure DevOps YAML Pipelines Steps
1. Create a new YAML pipeline. Hint - Use the Azure DevOps web interface to get intellisense
1. Run on an ubuntu agent
1. Create restore, build and publish steps, ensuring to use the Release configuration
1. Publish the code as a pipeline artifact 
1. Run the pipeline

## API App Continuous Delivery with Azure DevOps YAML Pipelines Steps
1. Create a new stage for deploying to dev.
1. Create a deployment job
1. Deploy the code to the app service using a service connection

## Module Completion Criteria
1. Show your coach the ability to list, add and update a product via the Web UI with your App deployed to Azure
1. Show your coach the output of all three Azure DevOps Pipelines