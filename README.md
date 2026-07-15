# Milde Docker Image Template

LinuxServer.io-inspired Docker image template for self-built homelab images.

## Goals

- Build our own images with a consistent LinuxServer.io-style runtime.
- Prefer upstream application artifacts/images when compatible.
- Use s6-overlay v3 service supervision via LinuxServer.io baseimages.
- Publish to GHCR and Docker Hub first; keep GitLab/Codeberg mirroring deployable.
- Support broad multi-architecture builds, including Raspberry Pi where upstream packages allow it.
- Use `make` for repeatable local workflows such as secure secret generation, linting, builds, and smoke tests.

## Pilot images

- `examples/postgresql`
- `examples/mariadb`

## Architecture policy

| Tier | Platforms | Policy |
|---|---|---|
| Tier 1 | `linux/amd64`, `linux/arm64` | Required for all images. |
| Tier 2 | `linux/arm/v7` | Required when upstream/runtime packages support it; Raspberry Pi 2/3/4 32-bit target. |
| Tier 3 | `linux/arm/v6`, `linux/386`, `linux/ppc64le`, `linux/s390x` | Best effort only; many modern upstream images/packages do not support these. |

**Reality note:** "Compatible with everything" is a goal, not a magic spell. Modern database engines and baseimages often drop older 32-bit targets. We record support explicitly per image instead of pretending.

## Quick start

```bash
# show available commands
make help

# generate local Docker secret files without printing values
make secrets

# lint static files
make lint

# build one pilot image on a Docker-capable host
IMAGE_TAG=dev PLATFORMS=linux/amd64 make build-postgresql
```

## Secret handling

See `docs/secrets.md`.

Default secrets are generated with Python's `secrets` module, 96 alphanumeric characters, mode `0600`, and no overwrite unless `FORCE=1` is set.

## Licensing summary

See `docs/licensing.md`.

- PostgreSQL: permissive PostgreSQL License-style copyright notice; redistribution generally compatible.
- MariaDB Server: GPL-2.0; redistribution is allowed but source/license obligations must be respected.

This is not legal advice. It is a homelab build system, not a law firm wearing a Docker logo.
