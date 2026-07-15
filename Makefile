.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SECRET_DIR ?= secrets
SECRET_LENGTH ?= 96
SECRET_NAME ?=
FORCE ?= 0
IMAGE_TAG ?= dev
PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7

.PHONY: help lint secrets secret-postgresql secret-mariadb clean-secrets build-postgresql build-mariadb smoke-postgresql smoke-mariadb

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make <target> [VAR=value]\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %-22s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Run static repository checks.
	@scripts/lint-static.sh

secrets: secret-postgresql secret-mariadb ## Generate all pilot secrets with secure defaults.

secret: ## Generate one secret file: make secret SECRET_NAME=path/to/file [SECRET_LENGTH=96] [FORCE=1].
	@if [[ -z "$(SECRET_NAME)" ]]; then echo "ERROR: set SECRET_NAME=path/to/file" >&2; exit 2; fi
	@scripts/generate-secret.py --path "$(SECRET_NAME)" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

secret-postgresql: ## Generate PostgreSQL pilot password secret.
	@scripts/generate-secret.py --path "examples/postgresql/$(SECRET_DIR)/postgres_password.txt" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

secret-mariadb: ## Generate MariaDB pilot app/root password secrets.
	@scripts/generate-secret.py --path "examples/mariadb/$(SECRET_DIR)/mysql_password.txt" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)
	@scripts/generate-secret.py --path "examples/mariadb/$(SECRET_DIR)/mysql_root_password.txt" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

clean-secrets: ## Delete generated local pilot secrets. Dangerous; prompts unless FORCE=1.
	@if [[ "$(FORCE)" != "1" ]]; then echo "Refusing to delete secrets without FORCE=1" >&2; exit 2; fi
	@rm -rf examples/postgresql/$(SECRET_DIR) examples/mariadb/$(SECRET_DIR)
	@echo "Deleted generated pilot secrets."

build-postgresql: ## Build PostgreSQL pilot image locally or through buildx args.
	@IMAGE_NAME=postgresql-lsio IMAGE_TAG="$(IMAGE_TAG)" DOCKERFILE=examples/postgresql/Dockerfile CONTEXT=examples/postgresql PLATFORMS="$(PLATFORMS)" ./scripts/buildx-build.sh

build-mariadb: ## Build MariaDB pilot image locally or through buildx args.
	@IMAGE_NAME=mariadb-lsio IMAGE_TAG="$(IMAGE_TAG)" DOCKERFILE=examples/mariadb/Dockerfile CONTEXT=examples/mariadb PLATFORMS="$(PLATFORMS)" ./scripts/buildx-build.sh

smoke-postgresql: ## Smoke-test local PostgreSQL pilot image.
	@./examples/postgresql/smoke-test.sh postgresql-lsio:$(IMAGE_TAG)

smoke-mariadb: ## Smoke-test local MariaDB pilot image.
	@./examples/mariadb/smoke-test.sh mariadb-lsio:$(IMAGE_TAG)
