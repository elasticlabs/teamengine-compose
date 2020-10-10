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
    # Get last item for triggering positive return code at the end of the loop
    ets=`echo $i | awk -F "," '{print $1}'` \
    && tag=`echo $i | awk -F "," '{print $2}'` \
    # Clone directory
    && echo "[INFO] Processing $ets -> v$tag" \
    && git clone $ets \
    && ets_pwd=`echo $ets | awk -F "/" '{print $NF}' | sed 's/\.git//'` \
    # Build ETS
    && cd $ets_pwd \
    && git stash && git checkout $tag \
    && mvn clean package -DskipTests=true \
    && cd ..; \
  done

WORKDIR ${TE_BUILD_DIR}
RUN last_item=`tail -1 $ETS_FILE | awk -F "," '{print $1}' | awk -F "/" '{print $NF}' | sed 's/\.git//'` \
  && for i in `ls . | grep ets`; do \
    # Clarify if ETS of CTL, then move files where they belong to
    #    - Copy CTL files to $TE_BASE/scripts
    #    - If dependency libraries exist, then copy them to $TE_WEB_BASE/WEB-INF/lib
    zip_ctl_file=`ls ${i}/target/*.zip | grep -m 1 "ctl"` \
    && if ls ${i}/target/*.zip; \
      then \
        zip_dep_file=$(ls ${i}/target/*.zip | grep -m 1 "deps"); \
      fi \
    && [ -n $zip_ctl_file ] && echo "[INFO] Installing $zip_ctl_file at $TE_BASE/scripts" \
    && unzip -q -o $zip_ctl_file -d ${TE_BASE}/scripts \
    && if [ -n $zip_dep_file ]; \
      then \
        echo "[INFO] Installing $zip_dep_file at ${TE_WEB_BASE}/WEB-INF/lib"; \
        unzip -q -o $zip_dep_file -d ${TE_WEB_BASE}/WEB-INF/lib; \
      else \
        echo "[INFO] No dependance libraries found for package $ets"; \
      fi \
    # Do some cleanup and get ready for next loop
    && cd ${TE_BUILD_DIR} && unset zip_dep_file && unset zip_ctl_file \
    && [[ "$i" == "$last_item" ]] && break || echo "[INFO] Finished installation of $i"; \
  done 

CMD ["/usr/local/teamengine/bin/catalina.sh", "run"]