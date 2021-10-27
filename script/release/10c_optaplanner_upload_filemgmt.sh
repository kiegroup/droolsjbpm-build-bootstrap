#!/bin/bash -e

# parameters: FILEMGMT_KEY = $1
# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

optaplannerDocs=optaplanner@filemgmt.jboss.org:/docs_htdocs/optaplanner/release
optaplannerHtdocs=optaplanner@filemgmt.jboss.org:/downloads_htdocs/optaplanner/release
uploadDir=${kieVersion}_uploadBinaries

# create directories on filemgmt.jboss.org for new release
touch upload_version
echo "mkdir" $kieVersion > upload_version
chmod +x upload_version
sftp -i $1 -b upload_version $optaplannerDocs
sftp -i $1 -b upload_version $optaplannerHtdocs

# create directory optaplanner-docs for optaplanner on filemgmt.jboss.org
touch upload_optaplanner_docs
echo "mkdir optaplanner-docs" > upload_optaplanner_docs
chmod +x upload_optaplanner_docs
sftp -i $1 -b upload_optaplanner_docs $optaplannerDocs/$kieVersion

# create directory optaplanner-javadoc for optaplanner on filemgmt.jboss.org
touch upload_optaplanner_javadoc
echo "mkdir optaplanner-javadoc" > upload_optaplanner_javadoc
chmod +x upload_optaplanner_javadoc
sftp -i $1 -b upload_optaplanner_javadoc $optaplannerDocs/$kieVersion

# create directory optaplanner-wb-es-docs for optaplanner on filemgmt.jboss.org
touch upload_optaplanner_wb_es_docs
echo "mkdir optaplanner-wb-es-docs" > upload_optaplanner_wb_es_docs
chmod +x upload_optaplanner_wb_es_docs
sftp -i $1 -b upload_optaplanner_wb_es_docs $optaplannerDocs/$kieVersion

# *** copies optaplanner binaries and docs to filemgmt.jboss.org ***************************

# bins
scp -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/optaplanner-distribution-$kieVersion.zip $optaplannerHtdocs/$kieVersion

# docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/optaplanner-docs/* $optaplannerDocs/$kieVersion/optaplanner-docs
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/optaplanner-javadoc/* $optaplannerDocs/$kieVersion/optaplanner-javadoc
scp -r -i $1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $uploadDir/optaplanner-wb-es-docs/* $optaplannerDocs/$kieVersion/optaplanner-wb-es-docs


# remove files and directories for uploading optaplanner
rm -rf upload_*


