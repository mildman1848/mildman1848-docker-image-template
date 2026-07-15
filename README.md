# mildman1848 Docker Image Template

Reusable LinuxServer.io-inspired Docker image template for self-built homelab images.

## Goals

- Consistent LinuxServer.io-style runtime foundation.
- s6-overlay v3 supervision patterns.
- Secure `make` workflows for secrets and local automation.
- Reusable GitHub Actions workflow for multiarch Docker builds.
- Registry strategy: GHCR and Docker Hub first; GitLab/Codeberg registries after PostgreSQL and MariaDB are proven.

## What this repo is

This repository is the **template**. Real images live in their own repositories, for example:

- `postgresql`
- `mariadb`

PostgreSQL and MariaDB are deliberately not kept under `examples/`; they are validation projects and future standalone image repos.

## Quick start

```bash
make help
make lint
make secret SECRET_NAME=secrets/my_service_password.txt
```

## Design docs

- `docs/architecture.md`
- `docs/secrets.md`
- `docs/licensing.md`
- `docs/implementation-plan.md`

## Current local verification

Docker and Hadolint are expected for full verification. Template static checks run through:

```bash
make lint
```


## Standalone image repositories

The pilot images now live in standalone repositories named after the image:

- `postgresql`
- `mariadb`

Repository names match the image names. LSIO-style behavior is documented in the image metadata and README instead.
