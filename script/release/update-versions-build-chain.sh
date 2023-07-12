#!/bin/bash
set -e

newVersion=$1
repository=$(basename -s .git $(git config --get remote.origin.url))


mvnVersionsSet() {
    mvn -B -N -e versions:set -Dfull -DnewVersion="$newVersion" -DallowSnapshots=true -DgenerateBackupPoms=false
}

mvnVersionsUpdateParent() {
    mvn -B -N -e versions:update-parent -Dfull -DparentVersion="[$newVersion]" -DallowSnapshots=true -DgenerateBackupPoms=false
}

mvnVersionsUpdateChildModules() {
    mvn -B -N -e versions:update-child-modules -Dfull -DallowSnapshots=true -DgenerateBackupPoms=false
}

# Updates parent version and child modules versions for Maven project in current working dir
mvnVersionsUpdateParentAndChildModules() {
    mvnVersionsUpdateParent
    mvnVersionsUpdateChildModules
}


if [ "$repository" == "lienzo-core" ]; then
    mvnVersionsSet
    returnCode=$?

elif [ "$repository" == "lienzo-tests" ]; then
    mvnVersionsSet
    returnCode=$?

elif [ "$repository" == "droolsjbpm-build-bootstrap" ]; then
    # first build&install the current version (usually SNAPSHOT) as it is needed later by other repos
    mvn -B -U -Dfull clean install
    # extract old kie version
    kieOldVersion=$(grep -oP -m 2 '(?<=<version>).*(?=</version)' pom.xml| awk 'FNR==2')
    mvnVersionsSet
    # update latest released version property only for non-SNAPSHOT versions
    if [[ ! $newVersion == *-SNAPSHOT ]]; then
        sed -i "s/<latestReleasedVersionFromThisBranch>.*<\/latestReleasedVersionFromThisBranch>/<latestReleasedVersionFromThisBranch>$newVersion<\/latestReleasedVersionFromThisBranch>/" pom.xml
    fi
    # update version also for user BOMs, since they do not use the top level kie-parent
    cd kie-user-bom-parent
    mvnVersionsSet
    cd ..
    # the child poms (all boms/pom.xml) have to be updated
    mvnVersionsUpdateChildModules
    # update version that are not automatically updated
    sed -i "s/<version.org.kie>$kieOldVersion<\/version.org.kie>/<version.org.kie>$newVersion<\/version.org.kie>/" pom.xml
    # workaround for http://jira.codehaus.org/browse/MVERSIONS-161
    mvn -B clean install -DskipTests
    returnCode=$?

elif [ "$repository" == "kie-soup" ]; then
    mvnVersionsUpdateParentAndChildModules
    returnCode=$?

elif [ "$repository" == "appformer" ]; then
    # extract old kie version
    kieOldVersion=$(grep -oP -m 1 '(?<=<version>).*(?=</version)' pom.xml)
    mvnVersionsSet
    # update version that are not automatically updated
    sed -i "s/<version>$kieOldVersion<\/version>/<version>$newVersion<\/version>/" pom.xml
    returnCode=$?

elif [ "$repository" == "jbpm" ]; then
    mvnVersionsUpdateParentAndChildModules
    returnCode=$?
    sed -i "s/release.version=.*$/release.version=$newVersion/" jbpm-installer/src/main/resources/build.properties

elif [ "$repository" == "process-migration-service" ]; then
    # extract old kie version
    kieOldVersion=$(grep -oP -m 2 '(?<=<version>).*(?=</version)' pom.xml | sed -n 2p)
    # update version since no mvn command works
    sed -i "s/<version>$kieOldVersion<\/version>/<version>$newVersion<\/version>/" pom.xml
    returnCode=$?

else
    mvnVersionsUpdateParentAndChildModules
    returnCode=$?
fi

if [ $returnCode != 0 ] ; then
    exit $returnCode
fi