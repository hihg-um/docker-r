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

RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
	apt-utils bzip2 curl dirmngr make \
	software-properties-common wget 

WORKDIR /app
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN wget -qO- \
	https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
	tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu \
		$(lsb_release -cs)-cran40/" && \
	add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
	apt -y update

RUN DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends \
	r-cran-curl r-cran-foreach \
	r-cran-genetics r-cran-ggplot2 \
	r-cran-iterators r-cran-knitr \
	r-cran-optparse r-cran-qqman r-cran-remotes r-cran-rmarkdown \
	r-cran-testthat r-cran-tidyverse

# FROM builder as release
# FROM base as builder

RUN DEBIAN_FRONTEND=noninteractive apt -y install \
	gcc g++ gfortran \
	libblas-dev liblapack-dev \
	libbz2-dev libcurl4-openssl-dev libsqlite3-dev \
	libxml2-dev libz-dev libzstd-dev \
	make uuid-dev

RUN apt -y install --install-recommends --install-suggests \
	r-cran-bitops r-cran-devtools

WORKDIR /app

RUN Rscript -e 'install.packages("seqminer")'
RUN Rscript -e 'install.packages("withr")'
RUN Rscript -e 'install.packages("RCurl")'

RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("BiocVersion")'
RUN Rscript -e 'BiocManager::install("zlibbioc")'
RUN Rscript -e 'BiocManager::install("gdsfmt")'
RUN Rscript -e 'BiocManager::install("BiocGenerics")'
RUN Rscript -e 'BiocManager::install("S4Vectors")'
RUN Rscript -e 'BiocManager::install("IRanges")'
RUN Rscript -e 'BiocManager::install("XVector")'
RUN Rscript -e 'BiocManager::install("GenomeInfoDbData")'
RUN Rscript -e 'BiocManager::install("GenomeInfoDb")'
RUN Rscript -e 'BiocManager::install("GenomicRanges")'
RUN Rscript -e 'BiocManager::install("Biostrings")'
RUN Rscript -e 'BiocManager::install("SeqArray")'
RUN Rscript -e 'BiocManager::install("Biobase")'
RUN Rscript -e 'BiocManager::install("operator.tools")'
RUN Rscript -e 'BiocManager::install("mice")'
RUN Rscript -e 'BiocManager::install("formula.tools")'
RUN Rscript -e 'BiocManager::install("GWASExactHW")'
RUN Rscript -e 'BiocManager::install("logistf")'
RUN Rscript -e 'BiocManager::install("SeqVarTools")'
RUN Rscript -e 'BiocManager::install("formatR")'
RUN Rscript -e 'BiocManager::install("SparseM")'
RUN Rscript -e 'BiocManager::install("MatrixModels")'
RUN Rscript -e 'BiocManager::install("lambda.r")'
RUN Rscript -e 'BiocManager::install("futile.options")'
RUN Rscript -e 'BiocManager::install("plogr")'
RUN Rscript -e 'BiocManager::install("zoo")'
RUN Rscript -e 'BiocManager::install("quantreg")'
RUN Rscript -e 'BiocManager::install("futile.logger")'
RUN Rscript -e 'BiocManager::install("snow")'
RUN Rscript -e 'BiocManager::install("BH")'
RUN Rscript -e 'BiocManager::install("RSQLite")'
RUN Rscript -e 'BiocManager::install("DNAcopy")'
RUN Rscript -e 'BiocManager::install("sandwich")'
RUN Rscript -e 'BiocManager::install("lmtest")'
RUN Rscript -e 'BiocManager::install("quantsmooth")'
RUN Rscript -e 'BiocManager::install("plyr")'
RUN Rscript -e 'BiocManager::install("BiocParallel")'
RUN Rscript -e 'BiocManager::install("GWASTools")'
RUN Rscript -e 'BiocManager::install("SNPRelate")'
RUN Rscript -e 'BiocManager::install("igraph")'
RUN Rscript -e 'BiocManager::install("reshape2")'
RUN Rscript -e 'BiocManager::install("GENESIS")'
#RUN Rscript -e 'BiocManager::install("")'

RUN Rscript -e 'devtools::install_github("xihaoli/STAAR")'

# RUN Rscript -e 'devtools::install_github("genostats/Ravages")'

RUN Rscript -e 'devtools::install_github("cran/KnockoffScreen")'
RUN Rscript -e 'devtools::install_github("cran/SKAT")'
RUN Rscript -e 'devtools::install_github("cran/WGScan")'
RUN Rscript -e 'devtools::install_github("zilinli1988/SCANG")'
# see docker.io/zilinli/staarpipeline


# FROM builder as release

# Set the user and group. This will allow output only where the
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
	useradd -m -u $USERID -g $USERGID $USERNAME && \
	adduser $USERNAME $USERGNAME

USER $USERNAME

ENTRYPOINT [ "Rscript" ]
