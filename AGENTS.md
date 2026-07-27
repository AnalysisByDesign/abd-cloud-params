# Repository Guidelines

## Project Structure & Module Organization

This repository contains environment-specific parameters for the separate `abd-cloud` Terraform template runner; it does not contain Terraform modules. Platform defaults live in `global_config.sh` and `global_config.tfvars`. Account trees such as `abd-global/` and `abd-wordpress/` contain account settings, VPC resources, applications, storage, and per-domain DNS configuration. Deployment order and safeguards are defined in `sequence/prod.csv`.

Each resource directory normally pairs `*_config.sh` with `*_config.tfvars`. Shell files select the template (`build_resources`), state key (`statefile_basename`), and exported runtime values. Terraform variable files hold module inputs. Resource-specific assets, such as cloud-init scripts and public keys, belong in a local `files/` directory.

## Validation & Development Commands

There is no standalone build or local test suite. Validate configuration before submitting:

```bash
pre-commit install              # install repository hooks
pre-commit run --all-files      # run every configured check
terraform fmt -recursive -check # verify all .tfvars formatting
shellcheck --severity=warning $(find . -name '*_config.sh')
```

Actual plans and applies run through the `abd-cloud` template runner. Review the configuration cascade and the `protect`/`prevent` flags in `sequence/prod.csv` before invoking infrastructure operations.

## Coding Style & Naming Conventions

Use two-space indentation in HCL collections and standard `terraform fmt` alignment. Keep tags and environment values lowercase. Follow existing snake_case variable names and descriptive resource directories, for example `hosted-sites/example.com/dns_config.tfvars`. Bash configuration uses `#!/bin/bash`, quoted expansions, and explicit `export` statements. ShellCheck exclusions in `.shellcheckrc` account for variables sourced by the parent runner; do not add suppressions without justification.

## Testing Guidelines

Treat formatting and static analysis as the required test gate. For changed resources, verify that every shell config has a matching variable file, `build_resources` points to a valid template path, and `statefile_basename` remains unique. When adding a resource, add its ordered entry to `sequence/prod.csv` and inspect the resulting Terraform plan in the runner repository.

## Commit & Pull Request Guidelines

Recent commits use short, imperative summaries such as `Add Tulox secrets` or scoped forms like `Tulox: Add domain verification`. Keep commits focused on one configuration change. Pull requests should identify affected accounts/resources, explain sequence or safeguard changes, link the relevant issue, and include plan output or a concise impact summary. Never commit credentials, private keys, state files, or unreviewed secret values.
