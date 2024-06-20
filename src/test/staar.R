# SPDX-License-Identifier: GPL-2.0

# Example from
# https://github.com/xihaoli/STAAR/blob/master/docs/STAAR_vignette.html
library(Matrix)
library(STAAR)
library(MASS)
library(matrixStats)
genotype <- example$genotype
maf <- example$maf
snploc <- example$snploc
sum((maf>0)*(maf<0.05))
