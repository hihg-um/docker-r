# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
OS_BASE ?= ubuntu
OS_VER ?= 23.04

IMAGE_REPOSITORY ?=
DOCKER_IMAGE_BASE := $(ORG_NAME)

GIT_REV := $(shell git describe --always --tags --dirty)
DOCKER_TAG ?= $(GIT_REV)

DOCKER_BUILD_ARGS :=

BASE_LAYER := r-base-lunar
TOOLS := r-saige r-genesis
SIF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).sif)
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))

.PHONY: clean docker test $(TOOLS) $(DOCKER_IMAGES)

all: docker apptainer test

help:
	@echo "Targets: all clean test"
	@echo "         docker docker_clean docker_test docker_release"
	@echo "         apptainer apptainer_clean apptainer_test"
	@echo
	@echo "Docker containers:\n$(DOCKER_IMAGES)"
	@echo
	@echo "Apptainer images:\n$(SIF_IMAGES)"

clean: apptainer_clean docker_clean

docker: docker_base docker_tools

release: docker_release

test: docker_test apptainer_test

# Docker
docker_clean:
	for f in $(DOCKER_IMAGES); do \
		docker rmi -f $(DOCKER_IMAGE_BASE)/$$f 2>/dev/null; \
	done

docker_base:
	@echo "Building Base Layer"
	@docker build \
		-t $(DOCKER_IMAGE_BASE)/$(BASE_LAYER):$(DOCKER_TAG) \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		-f Dockerfile.$(BASE_LAYER) \
		.

docker_tools: $(TOOLS)

$(TOOLS):
	@echo "Building Docker container $@"
	@docker build \
 		-t $(DOCKER_IMAGE_BASE)/$@:$(DOCKER_TAG) \
 		$(DOCKER_BUILD_ARGS) \
 		--build-arg BASE_IMAGE=$(DOCKER_IMAGE_BASE)/$(BASE_LAYER):$(DOCKER_TAG) \
		-f Dockerfile.$@ \
		.

docker_test:
	for f in $(DOCKER_IMAGES); do \
		echo "Testing Docker image: $(DOCKER_IMAGE_BASE)/$$f"; \
		docker run -t $(DOCKER_IMAGE_BASE)/$$f; \
	done

docker_release: $(DOCKER_IMAGES)
	for f in $(DOCKER_IMAGES); do \
		docker push $(IMAGE_REPOSITORY)/$(DOCKER_IMAGE_BASE)/$$f; \
	done

# Apptainer
apptainer_clean:
	@rm -f $(SIF_IMAGES)
	@rm -f *.sif

apptainer: $(SIF_IMAGES)

$(SIF_IMAGES):
	@echo "Building Apptainer $@"
	@apptainer build $@ \
		docker-daemon:$(DOCKER_IMAGE_BASE)/$(patsubst %.sif,%,$@)

apptainer_test: $(SIF_IMAGES)
	for f in $(SIF_IMAGES); do \
		echo "Testing Apptainer image: $$f"; \
		apptainer run $$f; \
	done

