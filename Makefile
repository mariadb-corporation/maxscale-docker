IMAGE_NAME := mariadb/maxscale
MXS_VERSION ?=
IMAGE_TAG := $(IMAGE_NAME):$(MXS_VERSION)-ubi
USAGE := "Usage: make build-image MXS_VERSION=<mxs-version>"
REDHAT_PROJECT_ID ?=
REDHAT_API_KEY ?=
DOCKER_CONFIG ?= $(HOME)/.docker/config.json

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)
## Tool Binaries
PREFLIGHT ?= $(LOCALBIN)/preflight
## Tool Versions
PREFLIGHT_VERSION ?= 1.9.9

.PHONY: help

ifeq ($(MXS_VERSION), )
    $(error MXS_VERSION is empty. $(USAGE))
endif

help:
	@echo $(USAGE)

build-image:
	docker build -f Dockerfile -t $(IMAGE_TAG) --build-arg MXS_VERSION=$(MXS_VERSION) .

PREFLIGHT_IMAGE ?= ""
.PHONY: preflight-image
preflight-image: preflight ## Run preflight tests on the image.
	$(PREFLIGHT) check container $(PREFLIGHT_IMAGE) --docker-config $(DOCKER_CONFIG)

.PHONY: preflight-image-submit
preflight-image-submit: preflight ## Run preflight tests on the image and submit the results to Red Hat.
	$(PREFLIGHT) check container $(PREFLIGHT_IMAGE)\
		--submit \
		--pyxis-api-token=$(REDHAT_API_KEY) \
		--certification-project-id=$(REDHAT_PROJECT_ID)\
		--docker-config $(DOCKER_CONFIG) 

.PHONY: preflight
preflight: ## Download preflight locally if necessary.
ifeq (,$(wildcard $(PREFLIGHT)))
ifeq (,$(shell which preflight 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(PREFLIGHT)) ;\
	OS=$(shell uname | tr '[:upper:]' '[:lower:]') && \
	ARCH=$(shell uname -m) ;\
	if [ "$$ARCH" = "x86_64" ]; then ARCH="amd64"; fi ;\
	if [ "$$ARCH" = "aarch64" ]; then ARCH="arm64"; fi ;\
	curl -sSLo $(PREFLIGHT) https://github.com/redhat-openshift-ecosystem/openshift-preflight/releases/download/$(PREFLIGHT_VERSION)/preflight-$${OS}-$${ARCH} ;\
	chmod +x $(PREFLIGHT) ;\
	}
else
	PREFLIGHT := $(shell which preflight)
endif
endif
