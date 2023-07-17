ARG BASE_IMAGE
FROM $BASE_IMAGE as base

# SPDX-License-Identifier: GPL-2.0

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

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

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    python3-pip

RUN pip3 install cget

# install all possible R dependencies from pre-packaged ubuntu binaries
# - much faster install than 'install.packages() inside R'
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    r-base \
    r-cran-devtools \
    r-cran-qlcmatrix \
    r-cran-rcppparallel \
    r-cran-r.utils \
    r-cran-optparse \
    r-cran-roxygen2 \
    r-cran-rversions

# pick up remaining bioconductor dependencies not packaged w/ ubuntu    
RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("BiocVersion")'
RUN Rscript -e 'BiocManager::install("SPAtest")'
RUN Rscript -e 'BiocManager::install("RhpcBLASctl")'
RUN Rscript -e 'BiocManager::install("SKAT")'
RUN Rscript -e 'BiocManager::install("MetaSKAT")'

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git

WORKDIR /app
RUN git clone https://github.com/saigegit/SAIGE

# Force step_2 to use 1 single thread. More threads are ineffective
ENV OMP_NUM_THREADS=1

RUN R CMD INSTALL SAIGE

RUN mv SAIGE/extdata/step1_fitNULLGLMM.R SAIGE/extdata/step2_SPAtests.R SAIGE/extdata/step3_LDmat.R SAIGE/extdata/createSparseGRM.R /usr/local/bin/

RUN chmod a+x /usr/local/bin/step1_fitNULLGLMM.R
RUN chmod a+x /usr/local/bin/step2_SPAtests.R
RUN chmod a+x /usr/local/bin/step3_LDmat.R
RUN chmod a+x /usr/local/bin/createSparseGRM.R

RUN createSparseGRM.R  --help
RUN step1_fitNULLGLMM.R --help
RUN step2_SPAtests.R --help
RUN step3_LDmat.R --help

RUN apt-get update
RUN apt-get install time

USER $USERNAME

ENTRYPOINT [ "Rscript" ]
