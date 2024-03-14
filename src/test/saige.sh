#!/bin/bash
Rscript -e "library('SAIGE'); sessionInfo()"
step1_fitNULLGLMM.R -h
step2_SPAtests.R -h
step3_LDmat.R -h
createSparseGRM.R -h
extractNglmm.R -h