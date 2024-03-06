IMAGE_NAME := mariadb/maxscale
MXS_VERSION ?=
IMAGE_TAG := $(IMAGE_NAME):$(MXS_VERSION)-ubi
USAGE := "Usage: make build-image [MXS_VERSION=<mxs-version>]"

.PHONY: help

ifeq ($(MXS_VERSION), )
    $(error MXS_VERSION is empty. $(USAGE))
endif

help:
	@echo $(USAGE)

build-image:
	docker build -f Dockerfile -t $(IMAGE_TAG) --build-arg MXS_VERSION=$(MXS_VERSION) .
