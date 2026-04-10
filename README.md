# Infrastructure as Code with Bicep

This repository contains a subscription-scope Azure Bicep deployment for provisioning an application hosting baseline across multiple environments. The solution is organized around reusable modules and environment-specific parameter files so the same template can deploy development, test, staging, and production topologies with different scale and networking options.

## What this deploys

Depending on the selected environment parameters, the deployment can provision:

- A resource group
- A Linux App Service Plan
- One or more Linux Web Apps with system-assigned managed identities
- Optional user-assigned managed identities for shared workload identity scenarios
- Optional resource group scoped RBAC role assignments for managed identities
- An Azure Key Vault configured for RBAC authorization
- Optional Key Vault scoped RBAC role assignments for managed identities
- An application Virtual Network for App Service integration
- Network Security Groups for the app, gateway, and database subnet boundaries when enabled
- An Application Gateway with public IP and backend pool entries for the deployed web apps
- A secondary Virtual Network intended for a database tier
- Bidirectional VNet peering between application and secondary VNets (with configurable access in peering settings)
- A Log Analytics workspace
- An Application Insights instance (workspace-based)
- Optional App Service diagnostic settings routed to Log Analytics

All major resource groups are controlled by `deploymentToggles` in each `.bicepparam` file.

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
		|-- applicationInsights.bicep
		|-- appService.bicep
		|-- keyVault.bicep
		|-- keyVaultRoleAssignment.bicep
		|-- appServicePlan.bicep
		|-- logAnalyticsWorkspace.bicep
		|-- nsg.bicep
		|-- roleAssignment.bicep
		|-- resourceGroup.bicep
		|-- storageAccount.bicep
		|-- userAssignedIdentity.bicep
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

Creates a virtual network and one or more subnets, including delegations, service endpoints, and optional NSG associations.

### `modules/nsg.bicep`

Creates a Network Security Group and applies the environment-specific rule set passed from the parameter files.

### `modules/applicationGateway.bicep`

Creates an Application Gateway Standard_v2 instance with:

- Standard public IP
- Backend pool entries derived from deployed app hostnames
- HTTP listener, routing rule, and health probe

### `modules/vnetPeering.bicep`

Creates VNet peering resources. In `main.bicep`, this module is used for both app-to-db and db-to-app peerings.

### `modules/logAnalyticsWorkspace.bicep`

Creates a Log Analytics workspace used for centralized diagnostics and monitoring.

### `modules/applicationInsights.bicep`

Creates a workspace-based Application Insights resource and exposes its connection string.

### `modules/storageAccount.bicep`

Creates a storage account when enabled via `deploymentToggles.storageAccount`.

### `modules/keyVault.bicep`

Creates an Azure Key Vault with RBAC authorization enabled and configurable soft-delete and purge-protection behavior.

### `modules/userAssignedIdentity.bicep`

Creates user-assigned managed identities and returns principal and client IDs for downstream role assignments.

### `modules/roleAssignment.bicep`

Creates resource group scoped role assignments for a target principal using built-in Azure role definition IDs.

### `modules/keyVaultRoleAssignment.bicep`

Creates Key Vault scoped role assignments for a target principal using built-in Azure role definition IDs.

## Parameters expected by `main.bicep`

| Parameter | Type | Purpose |
|---|---|---|
| `environment` | `string` | Environment short code such as `dev` or `prd` |
| `resourceGroup` | `object` | Resource group suffix and tags |
| `storage` | `object` | Storage account SKU and access tier |
| `appServicePlan` | `object` | App Service Plan SKU and capacity |
| `appService` | `array` | One or more web app definitions |
| `userAssignedIdentities` | `array` | Optional user-assigned managed identity definitions |
| `roleAssignments` | `array` | Optional RBAC role assignments applied at resource group scope |
| `keyVault` | `object` | Optional Key Vault configuration |
| `keyVaultRoleAssignments` | `array` | Optional RBAC role assignments applied at Key Vault scope |
| `vnetApp` | `object` | App-tier VNet and subnet configuration |
| `vnetDb` | `object` | Secondary VNet configuration |
| `vnetAppDbPeering` | `object` | App-to-db and db-to-app peering settings |
| `observability` | `object` | Log Analytics, App Insights, and diagnostics configuration |
| `networkSecurity` | `object` | App, gateway, and db subnet NSG configuration |
| `deploymentToggles` | `object` | Per-resource deployment switches |

Identity and RBAC toggles:

- `deploymentToggles.userAssignedIdentities`
- `deploymentToggles.roleAssignments`
- `deploymentToggles.keyVault`
- `deploymentToggles.keyVaultRoleAssignments`

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
- Gateway subnet NSG rules enabled so Application Gateway ingress remains reachable when subnet enforcement is on

## Notes and current limitations

- The storage account module is commented out in `main.bicep`
- Application Gateway backend settings currently use HTTP on port 80
- App Service diagnostics are currently applied at the web app level only
- App and db subnet NSGs currently establish the security boundary and use Azure default rules unless environment-specific rules are added

## Suggested next improvements

1. Re-enable and wire the storage account module if storage is required.
2. Add explicit app and db subnet NSG rules once target flows and service dependencies are finalized.
3. Add HTTPS listener and certificate handling for Application Gateway.
4. Add tag standards and cost-allocation metadata in each environment parameter file.
5. Add CI validation with `az deployment sub validate` for every `.bicepparam` file.
