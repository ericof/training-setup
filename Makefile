SHELL := /bin/bash
CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

# Python checks
UV?=uv

# installed?
ifeq (, $(shell which $(UV) ))
  $(error "UV=$(UV) not found in $(PATH)")
endif


ROLES_DIR=roles
MODULES_PATH=plugins
LINT_PATH=inventory/* playbooks/*
INSTALL_STAMP := .install.stamp

.PHONY: all
all: build

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: ## This help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

$(INSTALL_STAMP): pyproject.toml
	@echo "🚀 Setting up devops"
	@echo "- Create virtual environment"
	@uv venv
	@echo "- Installing dependencies"
	@uv sync
	@echo "- Install Ansible Roles and Collections"
	@uv run ansible-galaxy install -r requirements.yml --force --no-deps
	@touch $(INSTALL_STAMP)

.PHONY: install
install: $(INSTALL_STAMP) ## Install dependencies and roles


.PHONY: clean
clean: ## Remove virtualenv and downloaded roles
	@echo "🚀 Cleanup the current environment"
	@rm -rf $(INSTALL_STAMP) .venv roles/*

.PHONY: format
format: $(INSTALL_STAMP) ## Format modules
	@echo "$(GREEN)==> Format ansible modules$(RESET)"
	@uvx ruff@latest check --select I --fix --config $(BACKEND_FOLDER)/pyproject.toml

.PHONY: lint-ruff
lint-ruff: $(INSTALL_STAMP) ## Lint Ansible modules
	@echo "$(GREEN)==> Lint ansible modules$(RESET)"
	@uvx ruff@latest check --fix --config $(BACKEND_FOLDER)/pyproject.toml

.PHONY: lint-ansible
lint-ansible: $(INSTALL_STAMP) ## Lint playbooks
	@echo "$(GREEN)==> Lint ansible files$(RESET)"
	@uv run ansible-lint ${LINT_PATH}

.PHONY: lint
lint: $(INSTALL_STAMP) ## Lint Codebase
	@echo "$(GREEN)==> Lint kitconcept-server codebase$(RESET)"
	make lint-ansible
	make lint-ruff

# Manage Environment
include .env
export

.PHONY: create-environment
create-environment: $(INSTALL_STAMP) ## Create training environment
	@echo "$(GREEN)==> Create training environment$(RESET)"
	@uv run ansible-playbook playbooks/bootstrap.yml

.PHONY: list-environment
list-environment: $(INSTALL_STAMP)  ## List training environment inventory
	@echo "$(GREEN)==> List training environment$(RESET)"
	@uv run ansible-playbook playbooks/inventory.yml

.PHONY: destroy-environment
destroy-environment: $(INSTALL_STAMP)  ## Destroy training environment
	@echo "$(GREEN)==> Destroy training environment$(RESET)"
	@uv run ansible-playbook playbooks/destroy.yml
