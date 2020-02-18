IMAGE_NAME := mariadb/maxscale
VERSION := 2.4.7-1
DEV_SUFFIX ?=

ifneq ($(DEV_SUFFIX), )
  LOCAL_IMAGE := $(IMAGE_NAME):$(VERSION)-dev-$(DEV_SUFFIX)-$(shell git rev-parse --short=6 HEAD)
else
  LOCAL_IMAGE := $(IMAGE_NAME):$(VERSION)
endif

.PHONY: help

help:
	@echo "Usage: make build-image [DEV_SUFFIX=<image suffix>]"

build-image:
	docker build -f maxscale/Dockerfile maxscale -t $(LOCAL_IMAGE) --build-arg VERSION=$(VERSION) --build-arg GIT_COMMIT=$(shell git rev-list -1 HEAD) --build-arg GIT_TREE_STATE=$(shell (git status --porcelain | grep -q .) && echo -dirty) --build-arg BUILD_TIME=$(shell date -u +%Y-%m-%d_%H:%M:%S)
