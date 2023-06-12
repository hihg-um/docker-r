ARG BASE_IMAGE
FROM $BASE_IMAGE as base

# SPDX-License-Identifier: GPL-2.0

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGNAME
ARG USERGID
ARG DEBIAN_FRONTEND=noninteractive

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
    USERID=${USERID:-65533} \
    USERGID=${USERGID:-nogroup}

# Set the user and group. This will allow output only where the
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
	useradd -m -u $USERID -g $USERGID $USERNAME && \
	adduser $USERNAME $USERGNAME

RUN apt -y update -qq && apt -y upgrade && \
	apt -y install \
		ca-certificates \
		curl \
		dirmngr \
		git \
		less \
		build-essential \
		wget \
		cmake \
		libopenblas-base \
		python3-pip

RUN apt -y install r-base r-cran-devtools

RUN pip install cget

WORKDIR /src
RUN git clone https://github.com/saigegit/SAIGE

RUN apt -y install r-cran-ellipsis r-cran-vctrs \
	r-cran-rsqlite r-cran-rcpp r-cran-rcppeigen \
	r-cran-rcpparmadillo r-cran-rcppparallel \
	r-cran-r.utils r-cran-data.table r-cran-matrix \
	r-cran-bh r-cran-optparse r-cran-dplyr \
	r-cran-dbplyr r-cran-roxygen2 r-cran-rversions \
	r-cran-qlcmatrix

RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("methods")'
RUN Rscript -e 'BiocManager::install("SPAtest")'
RUN Rscript -e 'BiocManager::install("RhpcBLASctl")'
RUN Rscript -e 'BiocManager::install("SKAT")'
RUN Rscript -e 'BiocManager::install("MetaSKAT")'

#RUN Rscript SAIGE/extdata/install_packages.R

RUN R CMD INSTALL SAIGE

WORKDIR /app

USER $USERNAME

ENTRYPOINT [ "Rscript" ]
