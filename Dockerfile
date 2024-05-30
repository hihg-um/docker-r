# SPDX-License-Identifier: GPL-2.0
# ------------------------------------------------------------------------------
ARG BASE_IMAGE
FROM $BASE_IMAGE

ENV TZ="UTC"

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install --no-install-recommends --no-install-suggests \
	apt-utils bzip2 ca-certificates curl r-base && apt -y clean && \
	rm -rf /tmp/*
# ------------------------------------------------------------------------------
