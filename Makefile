.PHONY: help pre lint molecule test check build clean shell version ansible-version

################################################################################
# variables
################################################################################

IMAGE_TAG ?= $(shell cat VERSION)
IMAGE_NAME ?= ansible-role-deploy-service:$(IMAGE_TAG)
UV ?= uv
DOCKER_RUN ?= docker run --rm -v $(CURDIR):/work:ro $(IMAGE_NAME)
DOCKER_RUN_INTERACTIVE ?= docker run --rm -it -v $(CURDIR):/work:ro $(IMAGE_NAME)

################################################################################
# general
################################################################################

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

pre: ## run pre-commit on all files
	$(UV) run --extra dev pre-commit run --all-files

lint: ## run ansible-lint
	$(UV) run --extra dev ansible-lint .

molecule: ## run Molecule tests
	$(UV) run --extra dev molecule test

test: molecule ## run test suite

check: pre molecule ## run all quality checks

################################################################################
# docker
################################################################################

build: ## build the local role test image
	docker build -t $(IMAGE_NAME) .

clean: ## remove the local role test image
	-docker rmi -f $(IMAGE_NAME)

shell: ## start an interactive shell in the local role test image
	$(DOCKER_RUN_INTERACTIVE) /bin/bash

version: ## show role version
	@cat VERSION

ansible-version: ## show Ansible version in the local role test image
	$(DOCKER_RUN) ansible --version
