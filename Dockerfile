# SPDX-License-Identifier: GPL-2.0
# ------------------------------------------------------------------------------
ARG BASE
FROM $BASE

# build-args
ARG BASE
ARG GIT_TAG
ARG GIT_REV
ARG BUILD_ARCH
ARG BUILD_REPO
ARG BUILD_TIME
ARG URL_NAME

LABEL org.opencontainers.image.authors="kms309@miami.edu,sxd1425@miami.edu"
LABEL org.opencontainers.image.base.digest=""
LABEL org.opencontainers.image.base.name="$BASE"
LABEL org.opencontainers.image.description="Base Image"
LABEL org.opencontainers.image.created="$BUILD_TIME"
LABEL org.opencontainers.image.url="${BUILD_REPO}/${URL_NAME}:${GIT_TAG}-${GIT_REV}_${BUILD_ARCH}"
LABEL org.opencontainers.image.source="https://github.com/hihg-um/docker-analytics"
LABEL org.opencontainers.image.version="$GIT_TAG"
LABEL org.opencontainers.image.revision="$GIT_REV"
LABEL org.opencontainers.image.vendor="The Hussman Institute for Human Genomics, The University of Miami Miller School of Medicine"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.title="Genomics Analysis Tools in R"

ENV TZ="UTC"

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install --no-install-recommends --no-install-suggests \
	ca-certificates \
	r-base \
	&& \
	apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/*
# ------------------------------------------------------------------------------
