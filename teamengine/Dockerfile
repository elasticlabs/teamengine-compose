FROM tomcat:7.0-jdk8

# Source and setup variables
ARG TE_WEBAPP
ARG TE_VERSION
ARG GIT_MAIL
ARG GIT_NAME
ENV TE_BUILD_DIR=/root/TE_BASE

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
    && chmod -R 755 teamengine \
    && echo "[SUCCESS] TEAMEngine official GIT cloned"

#Change directory, politely configure git and build packages
WORKDIR ${TE_BUILD_DIR}/teamengine
RUN git config --global user.email ${GIT_MAIL}\
    && git config --global user.name ${GIT_NAME} \
    && git stash \
    && git checkout ${TE_VERSION} \
    && mvn package -DskipTests=true \
    && mvn site -DskipTests=true 
    #debug -> && tree .

#
# Step (1/ ) -> Web application & Common libs
# Base directory (teamengine.war and teamengine-common-libs.zip)
#
# We move CATALINA_BASE (https://opengeospatial.github.io/teamengine/installation.html)
#   -> docs sub-directory contains PDF documentation
RUN mkdir -p ${TE_WEBAPP} \
  && for i in bin logs temp webapps work lib users; do mkdir -p ${TE_WEBAPP}/$i; done \
  && cp $CATALINA_HOME/bin/catalina.sh ${TE_WEBAPP}/bin/ \
  && cp -r $CATALINA_HOME/conf ${TE_WEBAPP} \
  && chmod -R 777 ${TE_WEBAPP} \
  # Deployment of the main WAR file + common libs
  && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-web/target/teamengine.war -d ${TE_WEBAPP}/webapps/teamengine \
  && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-web/target/teamengine-common-libs.zip -d ${TE_WEBAPP}/libs

#
# Step (2/ ) -> TEAMEngine commandline binaries
#   Command-line utils sub-directory contains scripts and libs (https://opengeospatial.github.io/teamengine/users.html)
RUN mkdir -p ${TE_WEBAPP}/TE_BASE \
    && mkdir -p ${TE_WEBAPP}/TE_BASE/utils \
    && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-console/target/teamengine-console-${TE_VERSION}-base.zip -d ${TE_WEBAPP}/TE_BASE/ \
    && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-console/target/teamengine-console-${TE_VERSION}-bin.zip -d ${TE_WEBAPP}/TE_BASE/utils/ \
    && chmod -R 777 ${TE_WEBAPP}/TE_BASE

# TEAMEngine base utilities and recommanded options
ENV CATALINA_BASE=${TE_WEBAPP}
ENV TE_BASE=${TE_WEBAPP}/TE_BASE
ENV CATALINA_OPTS="-server -Xmx1024m -XX:MaxPermSize=128m -DTE_BASE=$TE_BASE -Dderby.system.home=$DERBY_DATA"

# Step (3/ ) -> Docuemntation 
#   -> docs sub-directory contains PDF documentation
RUN echo "[INFO] Base directories " \
    && mkdir -p ${TE_WEBAPP}/TE_BASE/docs \
    && chmod -R 755 ${TE_WEBAPP}/TE_BASE/docs \
    && echo "[INFO] PDF documentation deployment into doc subdirectory" \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-console/target/pdf/teamengine-console.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-core/target/pdf/teamengine-core.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-resources/target/pdf/teamengine-resources.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-spi/target/pdf/teamengine-spi.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-spi-ctl/target/pdf/teamengine-spi-ctl.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-tests/target/pdf/teamengine-tests.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-virtualization/target/pdf/teamengine-virtualization.pdf ${TE_WEBAPP}/TE_BASE/docs/ \
    && cp ${TE_BUILD_DIR}/teamengine/teamengine-web/target/pdf/teamengine-web.pdf ${TE_WEBAPP}/TE_BASE/docs/

#
# Step (4/ ) -> Copy :
#      - User sample (default : teamadmin pwd: changeme)
#      - ROOT context file
#      - TEAMEngine Site defaults
COPY conf/users/* ${TE_WEBAPP}/TE_BASE/users/
COPY conf/ROOT.xml ${CATALINA_BASE}/conf/Catalina/localhost/ROOT.xml
# TE Site configuration files
RUN rm -rf ${TE_WEBAPP}/TE_BASE/resources/site/*
COPY conf/site/* ${TE_WEBAPP}/TE_BASE/resources/site/

CMD ["/usr/local/teamengine/bin/catalina.sh", "run"]