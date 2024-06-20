#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
Rscript -e "library('Matrix'); library(mice); library(GMMAT); \
	library(STAAR); sessionInfo();"
Rscript	"staar.R"

#    library('MultiSTAAR'); sessionInfo(); MultiSTAAR version; \
#    library('MetaSTAAR'); sessionInfo(); MetaSTAAR version;"
