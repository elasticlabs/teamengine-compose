FROM tomcat:7.0-jdk8

# Source and setup variables
ARG TE_BASE
ARG TE_VERSION
ARG GIT_MAIL
ARG GIT_NAME
ENV TE_BUILD_DIR=/root/TE_BUILD

# Create and set build directory
RUN mkdir ${TE_BUILD_DIR}
WORKDIR ${TE_BUILD_DIR}

# Supplementary packages deployment
RUN set -eux \
    && apt-get update \
	&& apt-get install -y --no-install-recommends \
		git unzip tree \
    # Clone TEAMEngine repository
    && git clone https://github.com/opengeospatial/teamengine.git \
    && chmod -R 755 teamengine

#Change directory, politely configure git and build packages
WORKDIR $TE_BUILD_DIR/teamengine
RUN git config --global user.email ${GIT_MAIL}\
    && git config --global user.name ${GIT_NAME} \
    && git stash \
    && git checkout ${TE_VERSION} \
    && mvn package \
    && mvn site \
    && tree .