#!/bin/sh
# Builds TEAMEngine test suites
# Two arguments are required:
#     -> From https://github.com/opengeospatial/teamengine-builder
#


ETS_FILE=te_repositories.csv

for i in `more $ETS_FILE`
  do
    ets=`echo $i | awk -F "," '{print $1}'`
    tag=`echo $i | awk -F "," '{print $2}'`

    # Clone directory
    echo "[INFO] Processing $url -> v$tag"
    git clone $ets
    ets_pwd=`echo $ets | awk -F "/" '{print $NF}' | sed 's/\.git//'`

    # Build ETS
    cd $ets_pwd
    git stash && git checkout $tag
    mvn clean package -DskipTests=true
    cd target
    # Clarify if ETS of CTL, then move files where they belong to
    #    - Copy CTL files to $TE_BASE/scripts
    #    - If dependency libraries exist, then copy them to $TE_WEB_BASE/WEB-INF/lib
    zip_ctl_file=`ls *ctl.zip | grep -m 1 "ctl"` \
      && zip_dep_file=`ls *deps.zip | grep -m 1 "deps"` \
      && [ -n $zip_dep_file ] \
      && echo "[INFO] Installing $zip_ctl_file at $TE_BASE/scripts" \
      && unzip -q -o $zip_ctl_file -d $TE_BASE/scripts \
      && [ -n "$zip_dep_file" ] \
      && echo "[INFO] Installing $zip_dep_file at $TE_WEB_BASE/WEB-INF/lib" \
      && unzip -q -o $zip_dep_file -d $TE_WEB_BASE/WEB-INF/lib \
      && wait 2

    cd ../..
  done
