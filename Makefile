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
	@{ \
	set -e ;\
	if ! command -v preflight >/dev/null 2>&1; then \
		PREFLIGHT_VERSION=$$(curl -s https://api.github.com/repos/redhat-openshift-ecosystem/openshift-preflight/releases/latest | jq -r .tag_name) ;\
		mkdir -p $(dir $(PREFLIGHT)) ;\
		OS=$$(uname | tr '[:upper:]' '[:lower:]') ;\
		ARCH=$$(uname -m) ;\
		if [ "$$ARCH" = "x86_64" ]; then ARCH="amd64"; fi ;\
		if [ "$$ARCH" = "aarch64" ]; then ARCH="arm64"; fi ;\
		curl -sSLo $(PREFLIGHT) https://github.com/redhat-openshift-ecosystem/openshift-preflight/releases/download/$$PREFLIGHT_VERSION/preflight-$$OS-$$ARCH ;\
		chmod +x $(PREFLIGHT) ;\
	else \
		PREFLIGHT=$$(command -v preflight) ;\
	fi \
	}
