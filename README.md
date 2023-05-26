---
page_type: sample
languages:
- bicep
- csharp
- yaml
- aspx-csharp
name: Secure 3-tier application on App Service and SQL Database with ASP.NET Core, Bicep and Azure DevOps
description: Example of deploying a secure 3 tier ASP.NET Core application to Azure App Service and SQL Database using Bicep and Azure DevOps Pipelines.
products:
- azure
- azure-app-service
- azure-sql-database
- azure-private-link
- azure-virtual-network
- azure-devops
- azure-active-directory
urlFragment: app-service-and-sql-database-3-tier-with-private-networking-and-auth
---

# Deploying a Secure 3 tier application on App Service and SQL Database with ASP.NET Core, Bicep and Azure DevOps

This repository is an example of deploying a 3 tier ASP.NET Core application to Azure App Service and SQL Database using Bicep and Azure DevOps Pipelines. It implements private networking with private end points and authentication on all tiers with Azure Active Directory.

## Content

| File/folder | Description |
|-------------|-------------|
| `api-app` | ASP.NET Core C# RESTful API Application for CRUD operations against SQL Database with Entity Framework. |
| `web-app` | ASP.NET Core C# UI Application for CRUD operations against the API Application. |
| `bicep` | Infrastructure as Code for deploying the 3 tier application with private networking and authentication. |
| `pipelines` | Azure DevOps YAML Pipelines to deploy the Infrastructure, API Application and Web Application. |
| `script` | PowerShell scripts used by the Azure DevOps pipelines to create app registrations and assign permissions in Azure Active Directory. |
| `lab-docs` | The modular open hack style docs for deploying the example in stages. |
| `.gitignore` | Define what to ignore at commit time. |
| `CHANGELOG.md` | List of changes to the sample. |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md` | This README file. |
| `LICENSE.md` | The license for the sample. |

## Features

This sample includes the following features:

* Bicep to create a SQL Database
* Bicep to create an API App Service
* Bicep to create a UI App Service
* Bicep to create a VNET and subnets
* Bicep to create private end points for API App Service and SQL Database
* Bicep to create VNET integration for API App Service and UI App Service
* Bicep to create User Assigned Managed Identity and Associated permissions for SQL Database Azure Active Directory Authentication
* Bicep to create App Registrations for API App Service and UI App Service
* C# MSAL Code for UI App Service to Authenticate to the API App Service
* PowerShell for Adding Managed Identity to SQL Database
* PowerShell for restricting down access for App Registrations
* Azure DevOps Pipelines for deploying Bicep and Application Code
* Bicep to create Azure DevOps Self-hosted Agents in Azure Container Instance with VNET integration for private deployments

What is missing?

* Front Door and Web Application Firewall
* Network Security Groups

The following diagram shows the architecture:

![Architecture Diagram](/lab-docs/3-tier-app.png)

## Getting Started

### Prerequisites

- Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
- An Azure Subscription: [Free Account](https://azure.microsoft.com/en-gb/free/search/)
- A Azure DevOps Organization: [Free Organization](https://aex.dev.azure.com/signup/)
- Visual Studio Code: [Download](https://code.visualstudio.com/download)
- Visual Studio Professional or Enterprise: [Download Free Trial](https://visualstudio.microsoft.com/downloads/)

### Installation

- Clone the repository locally and then follow the Demo / Lab.

### Quickstart

The instructions for this sample are in the form of a Lab. Follow along with them to get up and running. If you want to get right to the end, then just use the pipelines for Module 5.

## Demo / Lab

These lab descriptions are high level and designed to be prompts with hints for the hack.

- [Module 2 - API Development with SQL Backend](/lab-docs/module2.md)
- [Module 3 - UI Development with API Backend](/lab-docs/module3.md)
- [Module 4 - Private Endpoints](/lab-docs/module4.md)
- [Module 5 - Authentication](/lab-docs/module5.md)
- [Module 6 - Continuous Delivery](/lab-docs/module6.md)

## Resources

- [Example for API Code](https://devblogs.microsoft.com/visualstudio/web-api-development-in-visual-studio-2022)
- [Entity Framework Migrations](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/applying?tabs=dotnet-core-cli#idempotent-sql-scripts)
