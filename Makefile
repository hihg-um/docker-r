# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
PROJECT_NAME ?= r-saige
OS_BASE ?= ubuntu
OS_VER ?= 22.04

USER ?= `whoami`
USERID ?= `id -u`
USERGNAME ?= ad
USERGID ?= 1533

IMAGE_REPOSITORY :=
IMAGE := $(ORG_NAME)/$(USER)/$(PROJECT_NAME):latest

GIT_HASH ?= $(shell git log --format="%h" -n 1)

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

.PHONY: all build clean docker test test_docker test_apptainer

all: docker $(PROJECT_NAME).sif test

test: test_docker test_apptainer

test_docker:
	@echo "Testing docker image: $(IMAGE)"
	@docker run -it -v /mnt:/mnt $(IMAGE) --version

test_apptainer: $(PROJECT_NAME).sif
	@echo "Testing apptainer image: $(PROJECT_NAME).sif"
	@apptainer run $(PROJECT_NAME).sif --version

clean:
	@docker rmi -f --no-prune $(IMAGE)
	@rm -f $(PROJECT_NAME).sif

docker:
	@docker build -t $(IMAGE) \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGNAME=$(USERGNAME) \
		--build-arg USERGID=$(USERGID) \
		.

$(PROJECT_NAME).sif:
	@apptainer build $(PROJECT_NAME).sif docker-daemon:$(IMAGE)

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
