SHELL := /bin/bash
CURRENT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

ROLES_DIR=roles
MODULES_PATH=plugins
LINT_PATH=inventory/* playbooks/*

.PHONY: all
all: build

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: ## This help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bin/pip: ## Create Virtualenv
	@echo "$(GREEN)==> Setup Virtual Env$(RESET)"
	python3 -m venv .
	bin/pip install pip --upgrade

bin/black: bin/pip ## Install black
	@echo "$(GREEN)==> Setup Black$(RESET)"
	bin/pip install black

.PHONY: build
build: bin/pip ## Setup Ansible
	@echo "$(GREEN)==> Setup Virtual Env$(RESET)"
	bin/pip install -r requirements/requirements.txt --upgrade
	# Install Roles
	bin/ansible-galaxy install -r requirements/roles.yml --force --no-deps -p $(ROLES_DIR)
	# Install Collections
	bin/ansible-galaxy collection install -r requirements/collections.yml

.PHONY: clean
clean: ## Remove virtualenv and downloaded roles
	@echo "Clean"
	rm -rf bin lib lib64 include pyvenv.cfg roles/*

.PHONY: format
format: bin/black ## Format modules
	@echo "$(GREEN)==> Format ansible modules$(RESET)"
	./bin/black ${MODULES_PATH}

.PHONY: lint-black
lint-black: bin/black ## Lint Ansible modules
	@echo "$(GREEN)==> Lint ansible modules$(RESET)"
	./bin/black ${MODULES_PATH} --check

.PHONY: lint-ansible
lint-ansible: bin/ansible-lint ## Lint playbooks
	@echo "$(GREEN)==> Lint ansible files$(RESET)"
	./bin/ansible-lint ${LINT_PATH}

.PHONY: lint
lint: ## Lint Codebase
	@echo "$(GREEN)==> Lint kitconcept-server codebase$(RESET)"
	make lint-ansible
	make lint-black

# Manage Environment
-include .env
export

.PHONY: create-environment
create-environment: bin/ansible  ## Create training environment
	@echo "$(GREEN)==> Create training environment$(RESET)"
	./bin/ansible-playbook playbooks/bootstrap.yml


.PHONY: list-environment
list-environment: bin/ansible  ## List training environment inventory
	@echo "$(GREEN)==> List training environment$(RESET)"
	./bin/ansible-playbook playbooks/inventory.yml

.PHONY: destroy-environment
destroy-environment: bin/ansible  ## Destroy training environment
	@echo "$(GREEN)==> Destroy training environment$(RESET)"
	./bin/ansible-playbook playbooks/destroy.yml
