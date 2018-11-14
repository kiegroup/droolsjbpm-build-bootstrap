#!/bin/bash -e

# ***************************************************************************
#                                                                           *
# This script branches and upgrades to the next SNAPSHOT version            *
# the repositories                                                          *
#   kie-docker-ci-images (https://github.com/kiegroup/kie-docker-ci-images) *
#   kie-benchmarks (https://github.com/kiegroup/kie-benchmarks)             *
#   kie-cloud-test (https://github.com/kiegroup/kie-cloud-tests)            *
# These repositories are not in the repository-list.txt, but an upgrade and *
# a branching is needed.                                                    *
#                                                                           *
# ***************************************************************************

# checks how many files have changed after version upgrade
linesCount () {
   nrLines=$(git status -s | wc -l | awk '{ print $1 }')
   #echo "nrLines= "$nrLines
   if [ "$nrLines" -gt "$count" ]; then
     echo "version upgrade of $rep to $newSnapshot was faulty"
     exit 1
   fi
}


# ******************** kie-docker-ci-images ************************************

# kie-docker-ci-images
rep="kie-docker-ci-images"
git clone git@github.com:kiegroup/kie-docker-ci-images.git
cd kie-docker-ci-images
git checkout -b $newBranch master
git checkout master

# upgrade the versions to next SNAPSHOT
./scripts/update-versions.sh $newSnapshot -U

# count of pom.xml files with SNAPSHOT
count=$(grep -rli --exclude-dir="src" "snapshot" | grep pom.xml | wc -l)
linesCount

# add commits and pushes them to master and pushes also the new branch
git add .
git commit -m "upgraded to new $newSnapshot version"
git push origin $newBranch
git push origin master
cd ..

# ******************** kie-benchmarks ************************************

# kie-benchmarks
rep="kie-benchmarks"
git clone git@github.com:kiegroup/kie-benchmarks.git
cd kie-benchmarks
git checkout -b $newBranch master
git checkout master

# upgrade the versions to next SNAPSHOT
mvn -B -N -e versions:update-parent -Dfull -DparentVersion="[$newSnapshot]" -DallowSnapshots=true -DgenerateBackupPoms=false
mvn -B -N -e versions:update-child-modules -Dfull -DallowSnapshots=true -DgenerateBackupPoms=false

# do manual changes to pom files that were not changed in versin upgrade
sed -i -e "$!N;s/<version>$oldSnapshot<\/version>/<version>$newSnapshot<\/version>/;P;D" jbpm-benchmarks/kieserver-assets/pom.xml

# count of pom.xml files with SNAPSHOT
count=$(grep -rli --exclude-dir="src" "snapshot" | grep pom.xml | wc -l)
linesCount

# add commits and pushes them to master and pushes also the new branch
git add .
git commit -m "upgraded to new $newSnapshot version"
git push origin $newBranch
git push origin master
cd ..


# ********************* kie-cloud-tests ***********************************

# kie-cloud-tests
rep="kie-cloud-tests"
git clone git@github.com:kiegroup/kie-cloud-tests.git
cd kie-cloud-tests
git checkout -b $newBranch master
git checkout master

# upgrade the versions to next SNAPSHOT
mvn -B -N -e versions:update-parent -Dfull -DparentVersion="[$newSnapshot]" -DallowSnapshots=true -DgenerateBackupPoms=false
mvn -B -N -e versions:update-child-modules -Dfull -DallowSnapshots=true -DgenerateBackupPoms=false


# count of pom.xml files with SNAPSHOT
count=$(grep -rli --exclude-dir="src" "snapshot" | grep pom.xml | wc -l)
linesCount

# add commits and pushes them to master and pushes also the new branch
git add .
git commit -m "upgraded to new $newSnapshot version"
git push origin $newBranch
git push origin master
cd ..