.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SECRET_LENGTH ?= 96
SECRET_NAME ?=
FORCE ?= 0

.PHONY: help lint secret clean

help: ## Show this help.
	@echo "Usage: make <target> [VAR=value]"
	@echo ""
	@echo "Targets:"

	@echo "  lint                 Run static repository checks"
	@echo "  secret               Generate one secure local secret file"
	@echo "  clean                Remove local temporary files"

lint: ## Run static repository checks.
	@scripts/lint-static.sh

secret: ## Generate one secure local secret file.
	@if [[ -z "$(SECRET_NAME)" ]]; then echo "ERROR: set SECRET_NAME=path/to/file" >&2; exit 2; fi
	@scripts/generate-secret.py --path "$(SECRET_NAME)" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

clean: ## Remove local temporary files.
	@rm -rf .tmp
