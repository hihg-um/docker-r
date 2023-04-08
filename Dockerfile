ARG BASE_IMAGE
FROM $BASE_IMAGE

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
	apt -y install apt-utils bzip2 curl git wget \
	plink2 \
	r-base r-bioc-snpstats r-cran-caret r-cran-data.table r-cran-domc \
	r-cran-foreach r-cran-genetics r-cran-ggplot2 r-cran-glmnet \
	r-cran-inline r-cran-mass \
	r-cran-optparse r-cran-qqman \
	r-cran-rcpp r-cran-rcpparmadillo r-cran-readr r-cran-stringr \
	r-cran-tidyverse

#FROM base as builder

RUN apt -y install r-cran-devtools r-cran-parallelly
RUN Rscript -e 'devtools::install_github("cran/bigassertr")'
RUN Rscript -e 'devtools::install_github("cran/parallelly")'
RUN Rscript -e 'devtools::install_github("cran/bigreadr")'
RUN Rscript -e 'devtools::install_github("cran/SuperLearner")'

WORKDIR /usr/src/
RUN git clone https://github.com/hihg-um/PROSPER.git

# Set the user and group. This will allow output only where the
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
	useradd -m -u $USERID -g $USERGNAME $USERNAME && \
	adduser $USERNAME $USERGNAME

USER $USERNAME

ENTRYPOINT [ "Rscript" ]
