@description('Name for the container group')
param name string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'jaredfholgate/azure-devops-agent:0.0.1'

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 4

@description('The behavior of Azure runtime if container has stopped.')
param restartPolicy string = 'Always'

param subnetId string

param agentName string

param agentPool string

@secure()
param agentToken string

param agentAzureDevOpsUrl string



resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          environmentVariables: [
            {
              name: 'AZP_URL'
              value: agentAzureDevOpsUrl
            }
            {
              name: 'AZP_POOL'
              value: agentPool
            }
            {
              name: 'AZP_AGENT_NAME'
              value: agentName
            }
            {
              name: 'AZP_TOKEN'
              secureValue: agentToken
            }
            {
              name: 'RESOURCE_GROUP'
              value: resourceGroup().name
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    subnetIds: [
      { 
        id: subnetId
        name: 'build_agents_subnet'
      }
    ]
    ipAddress: {
      type: 'private'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
