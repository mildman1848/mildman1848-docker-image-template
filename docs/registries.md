# Registry Publishing

Publishing is enabled only after local build and smoke tests pass.

## Current targets

| Registry | Status | Image pattern |
|---|---|---|
| GHCR | prepared | `ghcr.io/mildman1848/<image>` |
| Docker Hub | prepared when `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` exist | `docker.io/<DOCKERHUB_USERNAME>/<image>` |
| GitLab Registry | optional | `registry.gitlab.com/mildman1848/<image>` |
| Codeberg/Forgejo Registry | optional, verify exact package path before first push | `codeberg.org/mildman1848/<image>` |

## Required secrets

Docker Hub:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

GitLab:

- `GITLAB_REGISTRY_USER`
- `GITLAB_REGISTRY_TOKEN`

Codeberg:

- `CODEBERG_REGISTRY_USER`
- `CODEBERG_REGISTRY_TOKEN`

## Safety policy

- Pull requests build but do not push.
- Manual `workflow_dispatch` with `push=true` is required for publishing.
- PostgreSQL and MariaDB must pass local smoke tests before enabling additional registry pushes.
