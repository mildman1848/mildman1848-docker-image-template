.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

IMAGE_NAME ?= image-template
APP_VERSION ?= 0.0.0
IMAGE_REVISION ?= mldm1
VERSION ?= $(APP_VERSION)-$(IMAGE_REVISION)
IMAGE_TAG ?= $(VERSION)
REGISTRY ?= ghcr.io/mildman1848
IMAGE_REF ?= $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
CONTAINER_NAME ?= $(IMAGE_NAME)-dev
DOCKERFILE ?= Dockerfile
CONTEXT ?= .
PLATFORMS ?= linux/amd64,linux/arm64
LOAD_PLATFORM ?= linux/amd64
DOCKER ?= docker
COMPOSE ?= docker compose
TRIVY ?= trivy
SYFT ?= syft
SECRET_LENGTH ?= 96
SECRET_DIR ?= secrets
SECRET_NAME ?=
FORCE ?= 0
SBOM_FORMAT ?= spdx-json
SBOM_OUTPUT ?= sbom/$(IMAGE_NAME)-$(IMAGE_TAG).spdx.json

.PHONY: help info version setup check-tools env-setup env-validate lint validate test \
	build build-multiarch build-manifest build-manifest-push inspect-manifest validate-manifest \
	scan trivy-scan sbom security-scan start stop restart status logs shell compose-up compose-down \
	secret secrets secrets-generate secrets-rotate secrets-info secrets-clean check-upstream baseimage-check \
	release-dry-run release clean clean-images require-dockerfile require-image

help: ## Show available targets.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target> [VAR=value]\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-22s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

info: ## Print image/build configuration.
	@printf 'IMAGE_NAME=%s\n' '$(IMAGE_NAME)'
	@printf 'APP_VERSION=%s\n' '$(APP_VERSION)'
	@printf 'IMAGE_REVISION=%s\n' '$(IMAGE_REVISION)'
	@printf 'VERSION=%s\n' '$(VERSION)'
	@printf 'IMAGE_REF=%s\n' '$(IMAGE_REF)'
	@printf 'DOCKERFILE=%s\n' '$(DOCKERFILE)'
	@printf 'CONTEXT=%s\n' '$(CONTEXT)'
	@printf 'PLATFORMS=%s\n' '$(PLATFORMS)'
	@printf 'LOAD_PLATFORM=%s\n' '$(LOAD_PLATFORM)'

version: ## Print only the combined image version.
	@printf '%s\n' '$(VERSION)'

setup: ## Install/check local build helper tools.
	@scripts/setup-tools.sh

check-tools: ## Verify required local commands.
	@missing=0; \
	for cmd in git curl jq $(DOCKER); do \
	  if ! command -v "$${cmd%% *}" >/dev/null 2>&1; then echo "ERROR: missing $${cmd}" >&2; missing=1; else echo "OK: $${cmd%% *} -> $$(command -v $${cmd%% *})"; fi; \
	done; \
	for cmd in hadolint actionlint $(TRIVY) $(SYFT); do \
	  if ! command -v "$${cmd%% *}" >/dev/null 2>&1; then echo "WARN: optional tool missing: $${cmd}" >&2; else echo "OK: $${cmd%% *} -> $$(command -v $${cmd%% *})"; fi; \
	done; \
	exit "$${missing}"

env-setup: ## Create .env from .env.example when present.
	@if [[ -f .env ]]; then echo 'OK: .env already exists'; \
	elif [[ -f .env.example ]]; then cp .env.example .env; chmod 600 .env; echo 'OK: created .env from .env.example'; \
	else echo 'INFO: no .env.example present; nothing to create'; fi

env-validate: ## Validate common environment defaults without printing secrets.
	@[[ '$(IMAGE_REVISION)' =~ ^mldm[0-9]+$$ ]] || { echo 'ERROR: IMAGE_REVISION must look like mldm<N>' >&2; exit 2; }
	@[[ -n '$(IMAGE_NAME)' ]] || { echo 'ERROR: IMAGE_NAME is empty' >&2; exit 2; }
	@echo 'OK: environment metadata looks sane'

lint: ## Run static repository checks.
	@scripts/lint-static.sh

validate: lint env-validate ## Run local validation checks that do not require an image.
	@echo 'OK: validation passed'

test: validate ## Alias for validation/smoke entrypoint in template-derived repos.
	@echo 'OK: template test target completed'

require-dockerfile:
	@test -f '$(DOCKERFILE)' || { echo "ERROR: $(DOCKERFILE) missing. Copy this template into an image repo before running this target." >&2; exit 2; }

require-image:
	@$(DOCKER) image inspect '$(IMAGE_REF)' >/dev/null 2>&1 || { echo "ERROR: image not found locally: $(IMAGE_REF)" >&2; echo "Run: make build IMAGE_NAME=$(IMAGE_NAME)" >&2; exit 2; }

build: require-dockerfile ## Build local single-platform image with --load.
	@DOCKER='$(DOCKER)' IMAGE_NAME='$(REGISTRY)/$(IMAGE_NAME)' IMAGE_TAG='$(IMAGE_TAG)' VERSION='$(VERSION)' IMAGE_REVISION='$(IMAGE_REVISION)' APP_VERSION='$(APP_VERSION)' DOCKERFILE='$(DOCKERFILE)' CONTEXT='$(CONTEXT)' PLATFORMS='$(LOAD_PLATFORM)' scripts/buildx-build.sh --load

build-multiarch: require-dockerfile ## Build multiarch image without pushing.
	@DOCKER='$(DOCKER)' IMAGE_NAME='$(REGISTRY)/$(IMAGE_NAME)' IMAGE_TAG='$(IMAGE_TAG)' VERSION='$(VERSION)' IMAGE_REVISION='$(IMAGE_REVISION)' APP_VERSION='$(APP_VERSION)' DOCKERFILE='$(DOCKERFILE)' CONTEXT='$(CONTEXT)' PLATFORMS='$(PLATFORMS)' scripts/buildx-build.sh

build-manifest: build-multiarch ## Alias for local multiarch manifest validation build.

build-manifest-push: require-dockerfile ## Build and push multiarch image manifest.
	@DOCKER='$(DOCKER)' IMAGE_NAME='$(REGISTRY)/$(IMAGE_NAME)' IMAGE_TAG='$(IMAGE_TAG)' VERSION='$(VERSION)' IMAGE_REVISION='$(IMAGE_REVISION)' APP_VERSION='$(APP_VERSION)' DOCKERFILE='$(DOCKERFILE)' CONTEXT='$(CONTEXT)' PLATFORMS='$(PLATFORMS)' scripts/buildx-build.sh --push

inspect-manifest: ## Inspect a local/remote image manifest.
	@$(DOCKER) buildx imagetools inspect '$(IMAGE_REF)'

validate-manifest: inspect-manifest ## Validate that the image manifest can be inspected.
	@echo 'OK: manifest is inspectable'

trivy-scan scan: require-image ## Run a local Trivy image scan.
	@$(TRIVY) image --severity HIGH,CRITICAL --exit-code 0 '$(IMAGE_REF)'

security-scan: ## Run repository and image security checks where possible.
	@$(TRIVY) config --severity HIGH,CRITICAL --exit-code 0 .
	@if $(DOCKER) image inspect '$(IMAGE_REF)' >/dev/null 2>&1; then $(MAKE) trivy-scan; else echo 'INFO: image not built locally; skipped image scan'; fi

sbom: require-image ## Generate a local SBOM with Syft.
	@mkdir -p "$$(dirname '$(SBOM_OUTPUT)')"
	@$(SYFT) '$(IMAGE_REF)' -o '$(SBOM_FORMAT)' > '$(SBOM_OUTPUT)'
	@printf 'OK: wrote %s\n' '$(SBOM_OUTPUT)'

start: require-image ## Start the built image as a background container.
	@$(DOCKER) rm -f '$(CONTAINER_NAME)' >/dev/null 2>&1 || true
	@$(DOCKER) run -d --name '$(CONTAINER_NAME)' '$(IMAGE_REF)'

stop: ## Stop/remove the dev container.
	@$(DOCKER) rm -f '$(CONTAINER_NAME)' >/dev/null 2>&1 || true

restart: stop start ## Restart the dev container.

status: ## Show dev container status.
	@$(DOCKER) ps -a --filter name='$(CONTAINER_NAME)'

logs: ## Show dev container logs.
	@$(DOCKER) logs '$(CONTAINER_NAME)'

shell: require-image ## Open an interactive shell in the image.
	@$(DOCKER) run --rm -it --entrypoint /bin/bash '$(IMAGE_REF)' || $(DOCKER) run --rm -it --entrypoint /bin/sh '$(IMAGE_REF)'

compose-up: ## Start docker-compose.yml if present.
	@test -f docker-compose.yml -o -f compose.yml || { echo 'ERROR: no docker-compose.yml/compose.yml present' >&2; exit 2; }
	@$(COMPOSE) up -d

compose-down: ## Stop docker-compose.yml if present.
	@test -f docker-compose.yml -o -f compose.yml || { echo 'ERROR: no docker-compose.yml/compose.yml present' >&2; exit 2; }
	@$(COMPOSE) down

secret: ## Generate one secure local secret file. Requires SECRET_NAME=path.
	@if [[ -z '$(SECRET_NAME)' ]]; then echo 'ERROR: set SECRET_NAME=path/to/file' >&2; exit 2; fi
	@scripts/generate-secret.py --path '$(SECRET_NAME)' --length '$(SECRET_LENGTH)' $(if $(filter 1 true yes,$(FORCE)),--force,)

secrets secrets-generate: ## Generate the default local app secret.
	@$(MAKE) secret SECRET_NAME='$(SECRET_DIR)/app_password.txt'

secrets-rotate: ## Rotate the default local app secret. Requires FORCE=1.
	@if [[ '$(FORCE)' != '1' ]]; then echo 'ERROR: set FORCE=1 to rotate secrets' >&2; exit 2; fi
	@$(MAKE) secret SECRET_NAME='$(SECRET_DIR)/app_password.txt' FORCE=1

secrets-info: ## Show local secret file metadata without values.
	@if [[ -d '$(SECRET_DIR)' ]]; then find '$(SECRET_DIR)' -type f -printf '%m %s %p\n' | sort; else echo 'INFO: no secret directory'; fi

secrets-clean: ## Remove generated local secrets. Requires FORCE=1.
	@if [[ '$(FORCE)' != '1' ]]; then echo 'ERROR: set FORCE=1 to delete secrets' >&2; exit 2; fi
	@rm -rf '$(SECRET_DIR)'/*

check-upstream baseimage-check: ## Print current pinned LSIO baseimage when Dockerfile exists.
	@if [[ -f '$(DOCKERFILE)' ]]; then grep -m1 '^FROM ghcr.io/linuxserver/baseimage-' '$(DOCKERFILE)' || true; else echo 'INFO: no Dockerfile in template repo'; fi

release-dry-run: ## Show tags/metadata that would be published.
	@printf 'Would publish image:\n  %s\n' '$(IMAGE_REF)'
	@printf 'Additional expected tags:\n  latest on default branch\n  sha-$$(git rev-parse --short HEAD 2>/dev/null || echo unknown)\n'
	@printf 'Platforms: %s\n' '$(PLATFORMS)'

release: ## Guarded release target; use workflow_dispatch/push=true first.
	@echo 'ERROR: release is intentionally not automated in the template. Use GitHub Actions workflow_dispatch with push=true after smoke tests.' >&2
	@exit 2

clean: ## Remove local temporary files.
	@rm -rf .tmp sbom

clean-images: ## Remove local built image. Requires FORCE=1.
	@if [[ '$(FORCE)' != '1' ]]; then echo 'ERROR: set FORCE=1 to remove images' >&2; exit 2; fi
	@$(DOCKER) image rm '$(IMAGE_REF)' || true
