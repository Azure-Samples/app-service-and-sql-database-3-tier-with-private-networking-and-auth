# Module 4 - Private Endpoints

## Objectives
1. Add private networking with a vnet and subnets
1. Add Azure DevOps Agents in Container Instances connected to your private network
1. Add private endpoint to the SQL Server
1. Add private endpoint to the API App Service
1. Block public access to SQL Database and API App Service

## Azure DevOps Steps
1. Create a new Agent Pool and make a note of the name

## Bicep IaC Steps
1. Add a Vnet
1. Add 4 Subnets for API App, Web App, Container Instance Agents and Private Endpoints. Hint: Delegation is required
1. Integrate the API App into it's subnet and ensure all outbound traffic is routed over the vnet. 
1. Integrate the Web App into it's subnet and ensure all outbound traffic is routed over the vnet.
1. Deploy 2 container instances with Azure DevOps Agents configured. Hint: You can use this docker image: `jaredfholgate/azure-devops-agent:0.0.1`
1. Ensure the container instance are integrated into their subnet and that they have a managed identity.
1. Add a private DNS Zone for SQL Server private endpoints and attach the the vnet.
1. Add a private DNS Zone for App Service private endpoints and attach the the vnet.
1. Add a private endpoint for the SQL Server in the private endpoints subnet and attach to the SQL Server.
1. Add a private endpoint for the API App Server in the private endpoints subnet and attach to the API App Service.
1. Run the IaC Pipeline to deploy the changes
1. Disable all public access to the SQL Server

## Azure DevOps YAML Pipeline for API and Web App Update Steps
1. Update the pipeline deployment stages to use the new self hosted agent pool
1. Run the Pipelines

## Module Completion Criteria
1. Show your coach the ability to list, add and update a product via the Web UI from your App deployed to Azure
1. Show your coach that you can no longer reach the SQL Server and API App Service from the Public Internet or Azure Services outside of your VNET
1. Show your coach the output of all three Azure DevOps Pipelines