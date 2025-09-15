IMAGE_REPO := mariadb/maxscale
MXS_VERSION ?=
IMAGE_NAME := $(IMAGE_REPO):$(MXS_VERSION)

.PHONY: help

help:
	@echo "Usage: make build-image [MXS_VERSION=<image suffix>]"

.PHONY: build-image

build-image:
ifeq ($(MXS_VERSION),)
$(error The MXS_VERSION variable must be provided on the command line. Example: make build_image MXS_VERSION=24.02.11)
endif

	docker build -f Dockerfile -t $(IMAGE_NAME) --build-arg MXS_VERSION=$(MXS_VERSION) .
