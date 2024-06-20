# SPDX-License-Identifier: GPL-2.0
# ------------------------------------------------------------------------------
ARG BASE
FROM $BASE

# build-args
ARG BASE
ARG GIT_REPO
ARG GIT_TAG
ARG GIT_REV
ARG BUILD_REPO

ENV TZ="UTC"

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install --no-install-recommends --no-install-suggests \
		apt-utils \
		bzip2 \
		curl \
		make \
		r-base \
		r-base-dev \
	&& \
	apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/*

LABEL org.opencontainers.image.authors="kms309@miami.edu,sxd1425@miami.edu"
LABEL org.opencontainers.image.base.digest=""
LABEL org.opencontainers.image.base.name="$BASE"
LABEL org.opencontainers.image.description="Genomics Analysis R Tools base container"
LABEL org.opencontainers.image.licenses="GPL-2.0"
LABEL org.opencontainers.image.ref.name="R base"
LABEL org.opencontainers.image.revision="${GIT_REV}"
LABEL org.opencontainers.image.source="https://${GIT_REPO}"
LABEL org.opencontainers.image.title="HIHG: R Library container base image"
LABEL org.opencontainers.image.url="${BUILD_REPO}"
LABEL org.opencontainers.image.vendor="The Hussman Institute for Human Genomics, The University of Miami Miller School of Medicine"
LABEL org.opencontainers.image.version="${GIT_TAG}"
# ------------------------------------------------------------------------------
