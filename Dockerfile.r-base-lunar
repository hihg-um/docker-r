# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE as base

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    r-base

