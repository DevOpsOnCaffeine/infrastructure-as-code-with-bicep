# Infrastructure as Code with Bicep

This repository contains a subscription-scope Azure Bicep deployment for provisioning an application hosting baseline across multiple environments. The solution is organized around reusable modules and environment-specific parameter files so the same template can deploy development, test, staging, and production topologies with different scale and networking options.

## What this deploys

Depending on the selected environment parameters, the deployment can provision:

- A resource group
- A Linux App Service Plan
- One or more Linux Web Apps with system-assigned managed identities
- An application Virtual Network for App Service integration
- An Application Gateway with public IP and backend pool entries for the deployed web apps
- A secondary Virtual Network intended for a database tier
- VNet peering from the application VNet to the secondary VNet

The storage account module exists in the repo but is currently not enabled in the main deployment.

## Repository structure

```text
.
|-- common-settings.json
|-- main.bicep
|-- main.dev.bicepparam
|-- main.tst.bicepparam
|-- main.stg.bicepparam
|-- main.prd.bicepparam
`-- modules/
		|-- applicationGateway.bicep
		|-- appService.bicep
		|-- appServicePlan.bicep
		|-- resourceGroup.bicep
		|-- storageAccount.bicep
		|-- vnet.bicep
		`-- vnetPeering.bicep
```

## Core design

- Deployment scope: `subscription`
- Shared defaults: `prefix`, `region`, and `location` are loaded from `common-settings.json`
- Environment selection: controlled by each `.bicepparam` file
- Naming convention: `${prefix}-${resourceType}-${environment}-${region}-${indexOrSuffix}`
- Parallel app deployment: web apps are deployed with `@batchSize(2)`

## Environment files

Each environment file uses `main.bicep` and overrides configuration for that stage.

| File | Environment | Typical shape |
|---|---|---|
| `main.dev.bicepparam` | Development | Single app, no VNet integration, no Application Gateway |
| `main.tst.bicepparam` | Test | Environment-specific test sizing and settings |
| `main.stg.bicepparam` | Staging | Pre-production configuration |
| `main.prd.bicepparam` | Production | Three apps, VNet integration enabled, Application Gateway enabled, secondary VNet enabled |

## Modules

### `modules/resourceGroup.bicep`

Creates the target resource group at subscription scope.

### `modules/appServicePlan.bicep`

Creates a Linux App Service Plan. The SKU tier is inferred from the SKU name.

### `modules/appService.bicep`

Creates a Linux Web App with:

- System-assigned managed identity
- HTTPS-only support
- Optional VNet integration
- Optional route-all through the integrated subnet

### `modules/vnet.bicep`

Creates a virtual network and one or more subnets, including delegations and service endpoints.

### `modules/applicationGateway.bicep`

Creates an Application Gateway Standard_v2 instance with:

- Standard public IP
- Backend pool entries derived from deployed app hostnames
- HTTP listener, routing rule, and health probe

### `modules/vnetPeering.bicep`

Creates a one-way peering from the application VNet to the secondary VNet.

### `modules/storageAccount.bicep`

Present in the repository but not currently referenced by `main.bicep`.

## Parameters expected by `main.bicep`

| Parameter | Type | Purpose |
|---|---|---|
| `environment` | `string` | Environment short code such as `dev` or `prd` |
| `resourceGroupConfig` | `object` | Resource group suffix and tags |
| `storageConfig` | `object` | Reserved for storage settings if storage is enabled later |
| `appServicePlanConfig` | `object` | App Service Plan SKU and capacity |
| `appServiceConfig` | `array` | One or more web app definitions |
| `vnetAppConfig` | `object` | App-tier VNet and Application Gateway switches |
| `vnetDbConfig` | `object` | Secondary VNet and peering configuration |

## Prerequisites

- Azure CLI installed
- Bicep CLI available through Azure CLI
- An Azure subscription where you can run subscription-scope deployments
- Permissions to create resource groups and the target resources

Optional local setup commands:

```powershell
az login
az account set --subscription <subscription-id-or-name>
az bicep upgrade
```

## Validate and deploy

Because `main.bicep` targets the subscription scope, use `az deployment sub` commands.

### Validate development

```powershell
az deployment sub validate \
	--location canadacentral \
	--template-file main.bicep \
	--parameters main.dev.bicepparam
```

### Deploy development

```powershell
az deployment sub create \
	--location canadacentral \
	--template-file main.bicep \
	--parameters main.dev.bicepparam
```

### Deploy production

```powershell
az deployment sub create \
	--location canadacentral \
	--template-file main.bicep \
	--parameters main.prd.bicepparam
```

If you change `location` in `common-settings.json`, keep the deployment command location aligned with that value.

## Outputs

The main deployment returns outputs for:

- Resource group ID and name
- App Service Plan ID and name
- App Service URLs
- Application VNet ID and name when enabled
- Application Gateway ID and public IP when enabled
- Secondary VNet ID and name when enabled
- VNet peering ID when enabled

## Example production behavior

The production parameter file currently enables the most complete topology:

- App Service Plan SKU `P3` with capacity `3`
- Three Linux App Services for .NET, Node.js, and PHP runtimes
- App-tier VNet integration enabled
- Application Gateway enabled
- Secondary VNet enabled for a separate database tier
- One-way peering from app VNet to database VNet

## Notes and current limitations

- The storage account module is commented out in `main.bicep`
- VNet peering is currently unidirectional; a reverse peering is not created
- Application Gateway backend settings currently use HTTP on port 80
- The `vnetDbConfig.region` value is present in parameter files but the main template uses the primary `region` value in naming for the secondary VNet module call

## Suggested next improvements

1. Re-enable and wire the storage account module if storage is required.
2. Add bidirectional VNet peering if the database tier requires return-path connectivity.
3. Add HTTPS listener and certificate handling for Application Gateway.
4. Add tag standards and cost-allocation metadata in each environment parameter file.
5. Add CI validation with `az deployment sub validate` for every `.bicepparam` file.
