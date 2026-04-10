# Copilot Instructions

## Purpose

Use this repository for Azure infrastructure-as-code work built with Bicep. Keep changes focused, predictable, and aligned with the current module-driven structure.

## Repository context

- The root deployment file is `main.bicep`.
- Deployment scope is `subscription`, not `resourceGroup`.
- Shared defaults are loaded from `common-settings.json`.
- Environment-specific values belong in `main.dev.bicepparam`, `main.tst.bicepparam`, `main.stg.bicepparam`, and `main.prd.bicepparam`.
- Reusable infrastructure modules live under `modules/`.

## Working rules

- Preserve the current module-based architecture. Prefer updating an existing module over duplicating resource definitions in `main.bicep`.
- Keep naming consistent with the existing pattern: `${prefix}-${resourceType}-${environment}-${region}-${indexOrSuffix}`.
- Do not change the deployment scope unless the task explicitly requires it.
- Prefer parameterization over hardcoding. Shared defaults go in `common-settings.json`; environment-specific overrides go in `.bicepparam` files.
- Keep production-safe defaults. Do not reduce production capacity, remove security settings, or disable HTTPS unless explicitly requested.
- Make the smallest viable change. Avoid unrelated refactors or formatting churn.

## Bicep-specific guidance

- Reuse the existing modules first: resource group, app service plan, app service, virtual network, application gateway, storage account, and VNet peering.
- Keep parameters and outputs explicit and minimal. Add new outputs only when they are operationally useful.
- When adding optional infrastructure, gate it behind boolean configuration flags in parameter objects when that matches the existing pattern.
- Respect existing loop and batching behavior for App Service deployments.
- If a resource belongs in a module, keep the module interface stable unless the task requires a breaking change.
- Prefer current API versions already used in the repository unless there is a clear reason to upgrade.

## Environment guidance

- `dev` should stay lightweight unless the request says otherwise.
- `prd` can enable the most complete topology, including VNet integration and Application Gateway.
- If a change affects all environments, update each `.bicepparam` file deliberately rather than assuming parity.
- If a new setting is only needed in one environment, do not add it everywhere without reason.

## Validation expectations

- For deployment guidance, use Azure CLI subscription-scope commands such as `az deployment sub validate` and `az deployment sub create`.
- If Bicep files are edited, validate syntax and diagnostics when practical before finishing.
- Call out any unresolved deployment risks, especially around naming, subnet sizing, peering direction, or SKU compatibility.

## Documentation guidance

- Keep `README.md` aligned with the real deployment behavior.
- If you add a new module, parameter, output, or environment behavior, update the README when the change is user-visible.
- Write documentation in plain Markdown with direct operational guidance and concrete examples.

## Avoid

- Do not embed secrets, keys, or sample credentials.
- Do not introduce parallel infrastructure patterns that conflict with the current design without explaining the tradeoff.
- Do not uncomment or enable the storage module unless the task explicitly requires storage.
- Do not assume bidirectional VNet peering exists; it currently does not.

## Preferred response style for this repo

- Be precise about which file should change and why.
- Mention Azure impact when a change affects cost, networking, identity, or availability.
- When reviewing changes, prioritize deployment correctness, idempotency, and environment drift.

## Scope of work

### Features Covered

Core Bicep Patterns:
- Subscription-scoped deployments (`targetScope = 'subscription'`)
- Modular architecture (4 dedicated modules: `resourceGroup`, `storage`, `appServicePlan`, `appService`)
- Reusable module functions (`buildNameWithHyphens`)
- Parameter files (`.bicepparam`) for 4 environments (`dev`, `tst`, `stg`, `prd`)
- Object-based configuration (`resourceGroupConfig`, `storageConfig`, `appServicePlanConfig`, `appServiceConfig`)
- Environment-specific parameter progression (`dev`/`tst`: `S1` -> `stg`: `S2` -> `prd`: `P3`)

Deployment Patterns:
- Loop deployments with `@batchSize(2)` for parallel execution
- Explicit dependency management (`dependsOn` arrays)
- Module scoping to resource groups (`scope: resourceGroup`)
- Single source of truth for naming (`resourceGroupName` variable)

Resource Features:
- Storage Account: Multiple SKUs (`Standard_LRS`/`GRS` -> `Premium_GRS`), access tiers (`Hot`/`Cool`)
- App Service Plan: Dynamic tier calculation based on SKU name, Linux hosting
- App Service: `.NET 8`, `Node.js 20`, `PHP 8.2` runtimes, system-assigned managed identity, site configuration customization (`HTTP/2`, `TLS 1.2`, `FTPS` disabled, HTTPS enforcement), `alwaysOn` settings
- Resource Group: Subscription-level creation with tags support

Configuration Features:
- JSON file loading for common settings (`loadJsonContent('common-settings.json')`)
- Parameter defaults and overrides
- Array looping for multiple app services
- Outputs collection from loops

### Remaining Features to Implement

Identity & Security (High Priority):
- User-assigned managed identities
- Key Vault integration (references to secrets)
- RBAC role assignments via Bicep (`Microsoft.Authorization/roleAssignments`)
- Application Insights instrumentation
- Diagnostic settings and logging
- Network Security Groups / firewall rules
- Private endpoints and private DNS integration

Networking (High Priority):
- Virtual networks (VNets)
- Subnets
- Network integration for App Service (VNET integration)
- Application Gateway or Traffic Manager
- Service endpoints

Recently implemented:
- Key Vault private endpoint support with private DNS zone linkage

Data & Configuration (Medium Priority):
- SQL Database or Cosmos DB modules
- Application settings and environment variables
- Connection strings in App Service config
- Secrets management from Key Vault

Advanced Patterns (Medium Priority):
- Conditional deployments (`condition` property on resources/modules)
- Deployment scripts (`Microsoft.Resources/deploymentScripts`)
- Linked templates or registry references
- Policy definitions and assignments
- Resource locks
- Deployment stacks

Documentation & Validation (Medium Priority):
- Metadata and descriptions on parameters
- Output descriptions
- Type definitions for complex objects
- Bicep linter configuration (`.bicepconfig.json`)
- Parameter validation rules
- Comments explaining business logic

CI/CD Integration (Lower Priority):
- Azure DevOps Pipeline integration
- GitHub Actions workflow for deployment
- Pre-deployment validation scripts
- Post-deployment approval gates

Advanced Bicep Features (Lower Priority):
- User-defined types (custom type definitions)
- Advanced decorators (`@minLength`, `@maxLength`, `@allowed`, etc.)
- Conditional expressions in parameters
- Array/object filtering functions
- Error handling patterns