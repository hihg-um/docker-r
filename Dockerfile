# SPDX-License-Identifier: GPL-2.0
# ------------------------------------------------------------------------------
ARG BASE_IMAGE
FROM $BASE_IMAGE

ENV TZ="UTC"

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install --no-install-recommends \
  apt-utils bzip2 curl make \
  r-base r-base-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*
# ------------------------------------------------------------------------------
