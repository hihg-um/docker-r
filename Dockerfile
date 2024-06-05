# SPDX-License-Identifier: GPL-2.0
# ------------------------------------------------------------------------------
ARG BASE
FROM $BASE

ENV TZ="UTC"

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install --no-install-recommends --no-install-suggests \
	ca-certificates \
	r-base \
	&& \
	apt -y clean && rm -rf /var/lib/apt/lists/* /tmp/*
# ------------------------------------------------------------------------------
