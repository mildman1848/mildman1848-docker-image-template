# Make Targets

This template provides the standard Make surface for LSIO-style image repositories. The goal is to keep common operations discoverable and boring.

Boring is good. Boring survives updates.

## Source synthesis

| Source repo family | Adopted pattern |
|---|---|
| `rclone`, `serpbear`, `tandoor` | broad build/multiarch/security/secrets/release target vocabulary |
| `abs-tracked` | pragmatic container ops: `start`, `stop`, `restart`, `status`, `logs`, `shell` |
| `audiobookshelf` | SBOM and security scan conventions |
| current pilots | `mldm<N>` versioning, LSIO/s6 checks, Git mirror workflow |

## Core targets

| Target | Purpose |
|---|---|
| `make help` | List available targets. |
| `make info` | Print image/build metadata. |
| `make version` | Print only `<upstream-version>-mldm<N>`. |
| `make setup` | Install/check local helper tools. |
| `make check-tools` | Verify required and optional commands. |
| `make env-setup` | Copy `.env.example` to `.env` with mode `0600`. |
| `make env-validate` | Validate image metadata such as `IMAGE_REVISION=mldm<N>`. |
| `make lint` | Run static repository checks. |
| `make validate` | Run lint plus metadata validation. |
| `make test` | Template-safe alias for validation. Derived repos may extend it. |

## Build and manifest targets

| Target | Purpose |
|---|---|
| `make build` | Build a local single-platform image with Buildx `--load`. |
| `make build-multiarch` | Build multiarch image without pushing. |
| `make build-manifest` | Alias for a multiarch validation build. |
| `make build-manifest-push` | Build and push a multiarch manifest. |
| `make inspect-manifest` | Inspect a local/remote manifest. |
| `make validate-manifest` | Fail if manifest inspection fails. |

Default platforms:

```text
linux/amd64,linux/arm64
```

`linux/arm/v7` is a Raspberry Pi compatibility goal, but must not be advertised until the selected base image and upstream packages actually publish compatible manifests.

## Security and SBOM targets

| Target | Purpose |
|---|---|
| `make security-scan` | Run Trivy config scan and image scan when the image exists locally. |
| `make trivy-scan` / `make scan` | Run Trivy image scan for the built image. |
| `make sbom` | Generate a Syft SBOM artifact under `sbom/`. |

When using `sudo docker` locally, pass the same Docker command into targets:

```bash
make build DOCKER='sudo docker'
make security-scan DOCKER='sudo docker'
make sbom DOCKER='sudo docker'
```

## Container operation targets

| Target | Purpose |
|---|---|
| `make start` | Start the built image as a dev container. |
| `make stop` | Stop/remove the dev container. |
| `make restart` | Restart the dev container. |
| `make status` | Show dev container state. |
| `make logs` | Show dev container logs. |
| `make shell` | Open `/bin/bash` or `/bin/sh` in the image. |
| `make compose-up` | Start a Compose example if present. |
| `make compose-down` | Stop a Compose example if present. |

## Secret targets

| Target | Purpose |
|---|---|
| `make secret SECRET_NAME=path` | Generate one secret file. |
| `make secrets-generate` / `make secrets` | Generate default `secrets/app_password.txt`. |
| `make secrets-rotate FORCE=1` | Rotate the default app secret. |
| `make secrets-info` | Show secret metadata only; never values. |
| `make secrets-clean FORCE=1` | Delete generated local secrets. |

Secret defaults:

- 96 alphanumeric characters
- Python `secrets` module / OS CSPRNG
- file mode `0600`
- no stdout secret value

## Release and upstream targets

| Target | Purpose |
|---|---|
| `make check-upstream` / `make baseimage-check` | Print pinned LSIO baseimage if a Dockerfile exists. |
| `make release-dry-run` | Show image refs, platforms, and tags that would be published. |
| `make release` | Intentionally blocked in the template. Use GitHub Actions `workflow_dispatch` first. |

## Required variables for derived image repos

| Variable | Example |
|---|---|
| `IMAGE_NAME` | `postgresql` |
| `APP_VERSION` | `16.14` |
| `IMAGE_REVISION` | `mldm1` |
| `REGISTRY` | `ghcr.io/mildman1848` |
| `PLATFORMS` | `linux/amd64,linux/arm64` |
