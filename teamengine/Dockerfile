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
    && mvn package -DskipTests=true
#
# Step (1/ ) -> Web application & Common libs
# Base directory (teamengine.war and teamengine-common-libs.zip)
#
# We move CATALINA_BASE (https://opengeospatial.github.io/teamengine/installation.html)
RUN mkdir -p ${TE_WEBAPP} \
  && for i in bin logs temp webapps work lib users; do mkdir -p ${TE_WEBAPP}/$i; done \
  && cp $CATALINA_HOME/bin/catalina.sh ${TE_WEBAPP}/bin/ \
  && cp -r $CATALINA_HOME/conf ${TE_WEBAPP} \
  && chmod -R 777 ${TE_WEBAPP} \
  # Deployment of the main WAR file + common libs
  && mkdir -p ${TE_WEBAPP}/webapps/app \
  && chmod 777 ${TE_WEBAPP}/webapps/app \
  && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-web/target/teamengine.war -d ${TE_WEBAPP}/webapps/app \
  && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-web/target/teamengine-common-libs.zip -d ${TE_WEBAPP}/lib

#
# Step (2/ ) -> TEAMEngine commandline binaries
#   Command-line utils sub-directory contains scripts and libs (https://opengeospatial.github.io/teamengine/users.html)
RUN mkdir -p ${TE_WEBAPP}/TE_BASE \
    && mkdir -p ${TE_WEBAPP}/TE_BASE/utils \
    && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-console/target/teamengine-console-${TE_VERSION}-base.zip -d ${TE_WEBAPP}/TE_BASE/ \
    && unzip -e ${TE_BUILD_DIR}/teamengine/teamengine-console/target/teamengine-console-${TE_VERSION}-bin.zip -d ${TE_WEBAPP}/TE_BASE/utils/ 

ENV CATALINA_BASE=${TE_WEBAPP}
ENV TE_WEB_BASE=${TE_WEBAPP}/webapps/app
ENV TE_BASE=${TE_WEBAPP}/TE_BASE
ENV CATALINA_OPTS="-server -Xmx1024m -DTE_BASE=$TE_BASE -Dderby.system.home=${TE_WEBAPP}/derby_data"

#
# Step (3/ ) -> Copy :
#      - User sample (default : teamadmin pwd: changeme)
#      - ROOT context file
#      - TEAMEngine Site defaults
COPY conf/users/* ${TE_WEBAPP}/TE_BASE/users/
# TE Site configuration files
RUN rm -rf ${TE_WEBAPP}/TE_BASE/resources/site/* \
    && chmod -R 777 ${TE_WEBAPP}/TE_BASE
COPY conf/site/* ${TE_WEBAPP}/TE_BASE/resources/site/

#
# Step (4/ ) -> ETS deployment :
#       - CSV list as input (see https://github.com/opengeospatial/teamengine-builder/)
#       - Basic shell script for ETS gather/build/deploy
WORKDIR ${TE_BUILD_DIR}
COPY conf/te_* ./
ENV ETS_FILE=te_repositories.csv

RUN rm -rf ets-* \
  && for i in `more $ETS_FILE | grep github`; do \
    ets=`echo $i | awk -F "," '{print $1}'` \
    && tag=`echo $i | awk -F "," '{print $2}'` \
    # Clone directory
    && echo "[INFO] Processing $ets -> v$tag" \
    && git clone $ets \
    && ets_pwd=`echo $ets | awk -F "/" '{print $NF}' | sed 's/\.git//'` \
    # Build ETS
    && git -C ${ets_pwd} stash && git -C ${ets_pwd} checkout $tag \
    && mvn clean package -f $ets_pwd/pom.xml -DskipTests=true \
    && if [ "$i" = "$(more $ETS_FILE | tail -1)" ] ; then break; else echo "[INFO] Finished building $i"; fi;\
  done

# After cloning & building, we simply dispatch generated zip into appropriate directories
# ... Then do a little cleanup
WORKDIR ${TE_BUILD_DIR}
RUN for i in `ls . | grep ets`; do \
      if [ $(ls ${i}/target | grep zip | wc -l) -gt 0 ] ; \
        then \
          zip_ctl_file=`ls ${i}/target/*.zip | grep -m 1 "ctl"`; \
          echo "[INFO] Installing $zip_ctl_file at $TE_BASE/scripts"; \
          unzip -q -o $zip_ctl_file -d ${TE_BASE}/scripts; \
          if [ $(ls ${i}/target | grep zip | grep dep | wc -l) -gt 0 ] ; \
          then \
            # We only consider optional libraries when they are actually available
            zip_dep_file=`ls ${i}/target/*.zip | grep -m 1 "dep"`; \
            echo "[INFO] Installing $zip_dep_file at ${TE_WEB_BASE}/WEB-INF/lib"; \
            unzip -o $zip_dep_file -d ${TE_WEB_BASE}/WEB-INF/lib; \
          else \
            echo "[INFO] No dependancy libs for $i ETS suite..."; \
          fi \
        fi \
      && cd ${TE_BUILD_DIR} \
      && if [ "$i" = "$(ls . | grep ets | tail -1)" ] ; then break; fi; \
    done 

CMD ["/usr/local/teamengine/bin/catalina.sh", "run"]