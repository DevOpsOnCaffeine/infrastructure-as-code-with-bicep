---
applyTo: '**/*.bicep'
description: 'Use when editing Bicep templates in this repository. Covers module reuse, subscription-scope deployment rules, naming conventions, environment handling, validation, and Azure-specific review priorities.'
---

# Bicep File Instructions

## Scope

Apply these instructions only when editing `.bicep` files in this repository.

## Repository rules

- The root deployment file is `main.bicep` and its target scope is `subscription`.
- Reusable resource definitions belong in `modules/`.
- Keep the current module-based structure. Prefer updating an existing module over defining duplicate resources in `main.bicep`.
- Preserve the existing naming convention: `${prefix}-${resourceType}-${environment}-${region}-${indexOrSuffix}`.

## Editing guidance

- Make the smallest viable infrastructure change.
- Prefer parameterization over hardcoding.
- Keep module interfaces stable unless the task explicitly requires a breaking change.
- Reuse existing modules first: resource group, app service plan, app service, virtual network, application gateway, storage account, and VNet peering.
- When adding optional behavior, gate it behind booleans in existing config objects when that fits the current pattern.
- Keep parameters and outputs explicit and minimal.
- Add outputs only when they are operationally useful.
- Prefer the API versions already used in the repo unless there is a concrete reason to change them.

## Environment and safety guidance

- Do not change deployment scope unless explicitly requested.
- Keep `dev` lightweight by default.
- Treat `prd` as the most complete and production-safe topology.
- Do not reduce production capacity, disable HTTPS, or remove security-related settings unless explicitly requested.
- Do not assume bidirectional VNet peering exists.
- Do not uncomment or enable the storage module unless the task explicitly requires storage.

## Validation and review expectations

- Validate Bicep syntax and diagnostics when practical after editing.
- Use subscription-scope Azure CLI guidance such as `az deployment sub validate` and `az deployment sub create` when documenting deployment steps.
- Call out unresolved risks around naming, subnet sizing, SKU compatibility, or peering direction.
- Prioritize deployment correctness, idempotency, and environment drift when reviewing changes.

## Documentation

- If a Bicep change affects behavior visible to users or operators, update `README.md`.
- Keep documentation direct, operational, and consistent with the actual deployment behavior.