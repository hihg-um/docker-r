# SPDX-License-Identifier: GPL-2.0

ORG_NAME ?= hihg-um
OS_BASE ?= ubuntu
OS_VER ?= 24.04

IMAGE_REPO ?= ghcr.io

#TOOLS := genesis gmmat prosper prsice saige seqmeta
TOOLS := genesis prosper prsice saige seqmeta

GIT_TAG = $(shell git describe --tags --exact-match)
GIT_REV = $(shell git describe --broken --dirty --all --long | \
		sed "s,heads/,," | sed "s,tags/,," | \
		sed "s,remotes/pull/.*/,," )
GIT_REPO_TAIL = $(patsubst docker-%,%,$(shell basename \
		`git remote --verbose | grep origin | grep fetch | \
		cut -f2 | cut -d ' ' -f1` | sed 's/.git//'))
GIT_SYNC ?= ($(shell git fetch 2>&1 && git diff @{upstream} 2>&1),)

DOCKER_BUILD_OPTS ?= "--progress=plain"
DOCKER_BUILD_TIME := "$(shell date -u)"
DOCKER_ARCH = $(shell uname -m)_$(shell uname -s | tr '[:upper:]' '[:lower:]')
DOCKER_TAG ?= $(GIT_REV)_$(DOCKER_ARCH)

DOCKER_BASE= $(ORG_NAME)/$(GIT_REPO_TAIL):$(DOCKER_TAG)
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))
DOCKER_IMAGES_TEST = $(DOCKER_IMAGES)
SIF_IMAGES := $(TOOLS:=_$(DOCKER_TAG).sif)

IMAGE_TEST := /test.sh

.PHONY: apptainer_clean apptainer_distclean apptainer_test \
	docker_base docker_clean docker_release $(TOOLS)

help:
	@echo "Targets: all build clean test release"
	@echo "         docker docker_base docker_clean docker_test docker_release"
	@echo "         apptainer apptainer_clean apptainer_distclean apptainer_test"
	@echo
	@echo "Docker container(s):"
	@for f in $(DOCKER_IMAGES); do \
		printf "\t$$f\n"; \
	done
	@echo
	@echo "Apptainer(s):"
	@for f in $(SIF_IMAGES); do \
		printf "\t$$f\n"; \
	done
	@echo

all: clean build test

build: docker apptainer

clean: apptainer_clean docker_clean

release: docker_release

test: docker_test apptainer_test

# Docker
docker: docker_base $(TOOLS)

$(TOOLS):
	@echo "Building Docker container: $(ORG_NAME)/$@:$(DOCKER_TAG)"
	@docker build \
		$(DOCKER_BUILD_OPTS) \
		-f Dockerfile.$@ \
		-t $(ORG_NAME)/$@:$(DOCKER_TAG) \
		--build-arg BASE=$(DOCKER_BASE) \
		--build-arg RUN_CMD=$@ \
		--build-arg GIT_REV=$(GIT_REV) \
		--build-arg GIT_TAG=$(GIT_TAG) \
		--build-arg BUILD_ARCH=$(DOCKER_ARCH) \
		--build-arg BUILD_REPO=$(IMAGE_REPO)/$(ORG_NAME) \
		--build-arg BUILD_TIME=$(DOCKER_BUILD_TIME) \
		.
	$(if $(GIT_SYNC),, \
		docker tag $(ORG_NAME)/$@:$(DOCKER_TAG) $(ORG_NAME)/$@:latest)

docker_base:
	@echo "Building Docker base: $(DOCKER_BASE)"
	@docker build -t $(DOCKER_BASE) \
		$(DOCKER_BUILD_OPTS) \
		--build-arg BASE=$(OS_BASE):$(OS_VER) \
		--build-arg GIT_REV=$(GIT_REV) \
		--build-arg GIT_TAG=$(GIT_TAG) \
		--build-arg BUILD_ARCH=$(DOCKER_ARCH) \
		--build-arg BUILD_REPO=$(IMAGE_REPO)/$(ORG_NAME) \
		--build-arg BUILD_TIME=$(DOCKER_BUILD_TIME) \
		--build-arg URL_NAME=$(GIT_REPO_TAIL) \
		.
	@docker inspect $(DOCKER_BASE)

docker_clean:
	@docker builder prune -f 1> /dev/null 2>& 1
	@for f in $(TOOLS); do \
		docker rmi -f $(ORG_NAME)/$$f:$(DOCKER_TAG) 1> /dev/null 2>& 1; \
	done
	@docker rmi -f $(DOCKER_BASE) 1> /dev/null 2>& 1

$(DOCKER_IMAGES_TEST):
	@echo
	@echo "Testing Docker container: $(ORG_NAME)/$@"
	@docker run -t \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		--entrypoint=$(IMAGE_TEST) \
		--user=$(shell echo `id -u`):$(shell echo `id -g`) \
		$(ORG_NAME)/$@

docker_test: $(DOCKER_IMAGES_TEST)

docker_release:
	@for f in $(GIT_REPO_TAIL):$(DOCKER_TAG) $(DOCKER_IMAGES); do \
		docker tag $(ORG_NAME)/$$f \
			$(IMAGE_REPO)/$(ORG_NAME)/$$f; \
		docker push $(IMAGE_REPO)/$(ORG_NAME)/$$f; \
	done

# Apptainer
apptainer: $(SIF_IMAGES)

$(SIF_IMAGES):
	@for f in $(DOCKER_IMAGES); do \
		echo "Building Apptainer: $@"; \
		apptainer pull docker-daemon:$(ORG_NAME)/$$f; \
	done

apptainer_clean:
	@for f in $(SIF_IMAGES); do \
		if [ -f "$$f" ]; then \
			printf "Cleaning up Apptainer: $$f\n"; \
			rm -f $$f; \
		fi \
	done
	@apptainer cache clean

apptainer_distclean:
	@rm -f *.sif

apptainer_test: $(SIF_IMAGES)
	@for f in $^; do \
		echo "Testing Apptainer: $$f"; \
		apptainer exec $$f $(IMAGE_TEST); \
	done
