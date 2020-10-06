FROM tomcat:7.0-jdk8

# Source and setup variables
ARG TE_BASE
ARG TE_VERSION
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

#Change directory and build packages
WORKDIR $TE_BUILD_DIR/teamengine
RUN git checkout ${TE_VERSION} \
    && mvn package \
    && mvn site \
    && tree .