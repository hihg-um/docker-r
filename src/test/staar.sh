#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
echo; echo "Testing STAAR"
Rscript -e "library('Matrix'); library('mice'); library('GMMAT'); \
	library('STAAR'); sessionInfo();"

echo; echo -r "Testing staar.R: "
Rscript /staar.R

echo; echo "Testing MultiSTAAR"
Rscript -e "library('Matrix'); library('mice'); library('GMMAT'); \
	library('STAAR'); library('MultiSTAAR'); sessionInfo();"

echo; echo "Testing MetaSTAAR"
Rscript -e "library('Matrix'); library('mice'); library('GMMAT'); \
	library('STAAR'); library('MultiSTAAR'); library('MetaSTAAR'); \
	sessionInfo();"
