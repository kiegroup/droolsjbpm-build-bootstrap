#!/bin/bash
set -e
# Update the version for for all droolsjbpm repositories

initializeWorkingDirAndScriptDir() {
    # Set working directory and remove all symbolic links
    workingDir=`pwd -P`

    # Go the script directory
    cd `dirname $0`
    # If the file itself is a symbolic link (ignoring parent directory links), then follow that link recursively
    # Note that scriptDir=`pwd -P` does not do that and cannot cope with a link directly to the file
    scriptFileBasename=`basename $0`
    while [ -L "$scriptFileBasename" ] ; do
        scriptFileBasename=`readlink $scriptFileBasename` # Follow the link
        cd `dirname $scriptFileBasename`
        scriptFileBasename=`basename $scriptFileBasename`
    done
    # Set script directory and remove other symbolic links (parent directory links)
    scriptDir=`pwd -P`
}


updateParentVersion() {
    mvn -B -N -s $settings versions:update-parent -Dfull\
     -DparentVersion=[$newVersion] -DallowSnapshots=true -DgenerateBackupPoms=false
}

updateChildModulesVersion() {
    mvn -N -B -s $settings versions:update-child-modules -Dfull\
     -DallowSnapshots=true -DgenerateBackupPoms=false
}

# Updates parent version and child modules versions for Maven project in current working dir
updateParentAndChildVersions() {
    updateParentVersion
    updateChildModulesVersion
}

initializeWorkingDirAndScriptDir
droolsjbpmOrganizationDir="$scriptDir/../../.."

if [ $# != 2 ]; then
    echo
    echo "Usage:"
    echo "  $0 releaseNewVersion R for remote settings.xml L for local settings.xml"
    echo "For example:"
    echo "  $0 6.3.0.Final R"
    echo
    exit 1
fi

if [ $2 == "R" ]; then
   settings=$scriptDir/update-version-all-settings.xml
else 
   settings=$HOME/.m2/kie-internal-settings.xml
fi

newVersion=$1
echo "New version is $newVersion"

startDateTime=`date +%s`

echo "settings.xml= " $settings
