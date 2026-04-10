---
applyTo: '**/*.bicepparam'
description: 'Use when editing Bicep parameter files in this repository. Covers environment-specific overrides, safe defaults, configuration placement, and validation guidance for .bicepparam files.'
---

# Bicep Parameter File Instructions

## Scope

Apply these instructions only when editing `.bicepparam` files in this repository.

## Repository rules

- Parameter files should use `main.bicep`.
- Shared defaults such as `prefix`, `region`, and `location` belong in `common-settings.json` unless the task explicitly requires a different pattern.
- Environment-specific values belong in `main.dev.bicepparam`, `main.tst.bicepparam`, `main.stg.bicepparam`, and `main.prd.bicepparam`.

## Editing guidance

- Keep overrides environment-specific and intentional.
- Do not copy a setting into every environment unless the change truly applies to all of them.
- If a new setting is required only for one environment, add it only there.
- Prefer consistency with existing object shapes such as `resourceGroupConfig`, `appServicePlanConfig`, `appServiceConfig`, `vnetAppConfig`, and `vnetDbConfig`.
- Keep values production-safe and avoid weakening existing security or availability settings.

## Environment expectations

- `dev` should stay lightweight unless requested otherwise.
- `prd` can carry the most complete topology, including VNet integration, Application Gateway, and secondary network configuration.
- Review `tst` and `stg` deliberately instead of assuming they should mirror either `dev` or `prd`.

## Validation and review expectations

- Ensure the parameter file still aligns with the parameters expected by `main.bicep`.
- When deployment guidance is needed, use subscription-scope Azure CLI commands such as `az deployment sub validate --parameters <file>`.
- Call out environment drift when a change affects one environment but not the others.
- Highlight cost, networking, identity, or availability impact when parameter changes alter those areas.

## Documentation

- Update `README.md` when parameter behavior changes in a way operators need to know about.
- Keep examples and deployment guidance aligned with the real parameter files.