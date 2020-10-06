FROM tomcat:7.0-jdk8

# Source and setup variables
ARG TE_WEBAPP
ARG TE_BASEDIR
ARG TE_VERSION
ARG TE_BUILD_DIR
ARG GIT_MAIL
ARG GIT_NAME
# TEAMEngine recommanded environment variables
ENV CATALINA_OPTS="-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=$TE_BASEDIR -Dderby.system.home=$DERBY_DATA"

# Create and set build directory
RUN mkdir ${TE_BUILD_DIR}
WORKDIR ${TE_BUILD_DIR}

# Supplementary packages deployment
RUN set -eux \
    && apt-get update \
	&& apt-get install -y --no-install-recommends \
		git unzip tree maven \
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

# 
# Main TEAMENgine installation
# Workdir : unchanged
# 
# Step (1/ ) -> Console base dir + TE PDF docs to ${TE_BASEDIR}
# Base directory (teamengine-console-5.4-base.zip)
#   -> docs sub-directory contains PDF documentation
RUN mkdir -p ${TE_BASEDIR} \ 
    && mkdir -p ${TE_BASEDIR}/docs\
    && chmod -R 755 ${TE_BASEDIR} \
    && unzip -e ${TE_BUILD_DIR}/teamengine-console/target/teamengine-console-${TE_VERSION}-base.zip -d ${TE_BASEDIR} \
    && cp ${TE_BUILD_DIR}/teamengine-console/pdf/teamengine-console.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-core/pdf/teamengine-core.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-resources/pdf/teamengine-resources.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-spi/pdf/teamengine-spi.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-spi-ctl/pdf/teamengine-spi-ctl.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-tests/pdf/teamengine-tests.pdf ${TE_BASEDIR}/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine-virtualization/pdf/teamengine-virtualization.pdf ${TE_BASEDIR}/docs/     

# Step (2/ ) -> Console utility scripts
# Base directory (teamengine-console-5.4-bin.zip)
#   -> utils sub-directory contains scripts and libs (https://opengeospatial.github.io/teamengine/users.html)
RUN mkdir -p ${TE_BASEDIR}/utils\
    && unzip -e ${TE_BUILD_DIR}/teamengine-console/target/teamengine-console-${TE_VERSION}-bin.zip -d ${TE_BASEDIR}/utils \
    && chmod -R 755 ${TE_BASEDIR}/utils

# Step (3/ ) -> Web application & Common libs
# Base directory (teamengine.war and teamengine-common-libs.zip)
#   -> docs sub-directory contains PDF documentation
RUN mkdir -p ${TE_WEBAPP} \
  && chmod -R 755 ${TE_WEBAPP} \
  && unzip -e ${TE_BUILD_DIR}/teamengine-web/target/teamengine-web.war -d ${TE_WEBAPP} \
  && cp ${TE_BUILD_DIR}/teamengine-web/pdf/teamengine-web.pdf ${TE_BASEDIR}/docs/ 

TODO TODO TODO / MOVE CATALINA_BASE (https://opengeospatial.github.io/teamengine/installation.html)

# Copy context file
COPY conf/ROOT.xml $CATALINA_HOME/conf/Catalina/localhost/ROOT.xml

CMD ["catalina.sh", "run"]