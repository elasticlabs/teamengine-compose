FROM tomcat:7.0-jdk8

# Source and setup variables
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
    && git checkout ${TE_VERSION} \
    && chmod -R 755 teamengine

WORKDIR $TE_BUILD_DIR/teamengine

# Maven 
RUN mvn package
RUN tree .