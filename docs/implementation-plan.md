# Docker Image Template Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task when expanding beyond this scaffold.

**Goal:** Build a reusable LinuxServer.io-style Docker image template and validate it with PostgreSQL and MariaDB pilot images.

**Architecture:** LSIO Alpine baseimage, s6-overlay v3 service definitions, shared scripts for secrets/config/healthchecks, reusable CI workflow for multiarch build and publish.

**Tech Stack:** Docker Buildx, GitHub Actions, GHCR, Docker Hub, optional GitLab/Codeberg mirrors, Hadolint, Trivy, SBOM generation.

---

## Task 1: Verify Docker-capable runner

**Objective:** Ensure a host can build and smoke-test multiarch images.

**Commands:**

```bash
docker --version
docker buildx version
docker run --rm hello-world
```

**Expected:** Docker and Buildx work. Current Hermes environment does not have Docker installed.

## Task 2: Build PostgreSQL pilot locally

```bash
IMAGE_NAME=postgresql-lsio IMAGE_TAG=dev DOCKERFILE=examples/postgresql/Dockerfile CONTEXT=examples/postgresql PLATFORMS=linux/amd64 ./scripts/buildx-build.sh --load
```

## Task 3: Smoke-test PostgreSQL

```bash
./examples/postgresql/smoke-test.sh postgresql-lsio:dev
```

## Task 4: Build MariaDB pilot locally

```bash
IMAGE_NAME=mariadb-lsio IMAGE_TAG=dev DOCKERFILE=examples/mariadb/Dockerfile CONTEXT=examples/mariadb PLATFORMS=linux/amd64 ./scripts/buildx-build.sh --load
```

## Task 5: Smoke-test MariaDB

```bash
./examples/mariadb/smoke-test.sh mariadb-lsio:dev
```

## Task 6: Enable registry publishing

Configure secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- GitHub `GITHUB_TOKEN` for GHCR
- optional `GITLAB_REGISTRY_USER` / `GITLAB_REGISTRY_TOKEN`

## Task 7: Add Renovate

Track:

- GitHub Actions
- Docker base images
- PostgreSQL/MariaDB package versions where feasible

## Task 8: Migrate first real app repo

Recommended order:

1. `FOSS-SmartHome-Planner`
2. `rclone`
3. `serpbear`
4. `abs-tracked`
5. `tandoor`
6. `audiobookshelf`
