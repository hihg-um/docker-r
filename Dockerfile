ARG BASE_IMAGE
FROM $BASE_IMAGE as base

# SPDX-License-Identifier: GPL-2.0

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGNAME
ARG USERGID

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
    USERID=${USERID:-65533} \
    USERGID=${USERGID:-nogroup}

RUN apt -y update -qq && apt -y upgrade && DEBIAN_FRONTEND=noninteractive \
	apt -y install apt-utils bzip2 curl wget

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	r-base \
	r-cran-devtools \
	r-bioc-snpstats \
	r-cran-genetics \
	r-cran-optparse \
	r-cran-qqman \
	r-cran-tidyverse \
	r-cran-data.table \
	r-cran-igraph \
	r-cran-matrix \
	r-cran-reshape2 \
	r-cran-r.utils \
	r-cran-ucminf \
	r-cran-ordinal \
	r-cran-shape \
	r-cran-pan \
	r-cran-jomo \
	r-cran-formatr \
	r-cran-glmnet \
	r-cran-mitml \
	r-cran-lambda.r \
	r-cran-futile.options \
	r-cran-mice \
	r-cran-rcurl \
	r-cran-futile.logger \
	r-cran-snow \
	r-cran-lmtest

RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("BiocVersion")'
RUN Rscript -e 'BiocManager::install("GenomeInfoDbData")'
RUN Rscript -e 'BiocManager::install("DNAcopy")'
RUN Rscript -e 'BiocManager::install("quantsmooth")'
RUN Rscript -e 'BiocManager::install("S4Vectors")'
RUN Rscript -e 'BiocManager::install("IRanges")'
RUN Rscript -e 'BiocManager::install("GenomeInfoDb")'
RUN Rscript -e 'BiocManager::install("XVector")'
RUN Rscript -e 'BiocManager::install("Biostrings")'
RUN Rscript -e 'BiocManager::install("Biobase")'
RUN Rscript -e 'BiocManager::install("BiocParallel")'
RUN Rscript -e 'BiocManager::install("gdsfmt")'
RUN Rscript -e 'BiocManager::install("GWASTools")'
RUN Rscript -e 'BiocManager::install("GenomicRanges")'
RUN Rscript -e 'BiocManager::install("SeqArray")'
RUN Rscript -e 'BiocManager::install("SeqVarTools")'
RUN Rscript -e 'BiocManager::install("SNPRelate")'
RUN Rscript -e 'BiocManager::install("GENESIS")'

# Set the user and group. This will allow output only where the
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
	useradd -m -u $USERID -g $USERGID $USERNAME && \
	adduser $USERNAME $USERGNAME

WORKDIR /app
RUN chown -R $USERNAME:$USERGID /app

USER $USERNAME
ENTRYPOINT [ "Rscript" ]
