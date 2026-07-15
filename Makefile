.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SECRET_LENGTH ?= 96
SECRET_NAME ?=
FORCE ?= 0

.PHONY: help setup check-tools lint secret clean

help: ## Show this help.
	@echo "Usage: make <target> [VAR=value]"
	@echo ""
	@echo "Targets:"
	@echo "  setup                Install/check local build helper tools"
	@echo "  check-tools          Verify required local commands"
	@echo "  lint                 Run static repository checks"
	@echo "  secret               Generate one secure local secret file"
	@echo "  clean                Remove local temporary files"

setup: ## Install/check local build helper tools.
	@scripts/setup-tools.sh

check-tools: ## Verify required local commands.
	@missing=0; 	for cmd in git curl jq hadolint actionlint docker; do 	  if ! command -v "$${cmd}" >/dev/null 2>&1; then echo "ERROR: missing $${cmd}" >&2; missing=1; else echo "OK: $${cmd} -> $$(command -v $${cmd})"; fi; 	done; 	if ! command -v trivy >/dev/null 2>&1; then echo "WARN: trivy missing; run make setup for scan-capable repos" >&2; fi; 	if ! command -v syft >/dev/null 2>&1; then echo "WARN: syft missing; run make setup for sbom-capable repos" >&2; fi; 	exit "$${missing}"

lint: ## Run static repository checks.
	@scripts/lint-static.sh

secret: ## Generate one secure local secret file.
	@if [[ -z "$(SECRET_NAME)" ]]; then echo "ERROR: set SECRET_NAME=path/to/file" >&2; exit 2; fi
	@scripts/generate-secret.py --path "$(SECRET_NAME)" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

clean: ## Remove local temporary files.
	@rm -rf .tmp
