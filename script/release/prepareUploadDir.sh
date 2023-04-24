#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' bc/kiegroup_droolsjbpm_build_bootstrap/pom.xml)
echo "kieVersion = "$kieVersion
deployDir=../community-deploy-dir

mkdir ${kieVersion}_uploadBinaries
cd ${kieVersion}_uploadBinaries

mkdir kie-api-javadoc
scp  $deployDir/org/kie/kie-api/$kieVersion/kie-api-$kieVersion-javadoc.jar kie-api-javadoc/
unzip kie-api-javadoc/kie-api-$kieVersion-javadoc.jar -d kie-api-javadoc/
rm kie-api-javadoc/kie-api-$kieVersion-javadoc.jar

mkdir jbpm-docs
cp  $deployDir/org/jbpm/jbpm-docs/$kieVersion/jbpm-docs-$kieVersion.zip jbpm-docs/
unzip jbpm-docs/jbpm-docs-$kieVersion.zip -d jbpm-docs/
rm jbpm-docs/jbpm-docs-$kieVersion.zip

# jbpm
cp $deployDir/org/jbpm/jbpm-distribution/$kieVersion/jbpm-distribution-$kieVersion-bin.zip jbpm-$kieVersion-bin.zip
cp $deployDir/org/jbpm/jbpm-distribution/$kieVersion/jbpm-distribution-$kieVersion-examples.zip jbpm-$kieVersion-examples.zip
cp $deployDir/org/kie/jbpm-server-distribution/$kieVersion/jbpm-server-distribution-$kieVersion-dist.zip jbpm-server-$kieVersion-dist.zip

# copies binaries + docs that are only available in /target directories - they are not deployed
mkdir service-repository
cp -r ../bc/kiegroup_jbpm_work_items/repository/target/repository-$kieVersion/* service-repository