#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' bc/kiegroup_droolsjbpm_build_bootstrap/pom.xml)

filemgmtServer=optaplanner@filemgmt-prod.jboss.org
rsync_filemgmt=optaplanner@filemgmt-prod-sync.jboss.org
optaplannerDocs=docs_htdocs/optaplanner/release
optaplannerHtdocs=downloads_htdocs/optaplanner/release
uploadDir=${kieVersion}_uploadBinaries

# create directory on filemgmt-prod.jboss.org for new release
touch create_version
echo "mkdir ${optaplannerDocs}/${kieVersion}" > create_version
echo "mkdir ${optaplannerHtdocs}/${kieVersion}" >> create_version
chmod +x create_version
sftp -b create_version $filemgmtServer

# create directory on filemgmt-prod.jboss.org for optaplanner-docs
touch create_optaplanner_docs_dir
echo "mkdir ${optaplannerDocs}/${kieVersion}/optaplanner-docs" > create_optaplanner_docs_dir
chmod +x create_optaplanner_docs_dir
sftp -b create_optaplanner_docs_dir $filemgmtServer

# create directory on filemgmt-prod.jboss.org for optaplanner-javadoc
touch create_optaplanner_javadoc_dir
echo "mkdir ${optaplannerDocs}/${kieVersion}/optaplanner-javadoc" > create_optaplanner_javadoc_dir
chmod +x create_optaplanner_javadoc_dir
sftp -b create_optaplanner_javadoc_dir $filemgmtServer

# create directory on filemgmt.jboss.org for optaplanner-wb-es-docs
touch create_optaplanner_wb_es_docs_dir
echo "mkdir ${optaplannerDocs}/${kieVersion}/optaplanner-wb-es-docs" > create_optaplanner_wb_es_docs_dir
chmod +x create_optaplanner_wb_es_docs_dir
sftp -b create_optaplanner_wb_es_docs_dir $filemgmtServer

# upload binaries to filemgmt-prod.jboss.org
touch upload_binaries
echo "put ${uploadDir}/optaplanner-distribution-${kieVersion}.zip ${optaplannerHtdocs}/${kieVersion}" > upload_binaries
chmod +x upload_binaries
sftp -b upload_binaries $filemgmtServer

# upload docs to filemgmt-prod.jboss.org
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/optaplanner-docs/* ${rsync_filemgmt}:${optaplannerDocs}/${kieVersion}/optaplanner-docs
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/optaplanner-javadoc/* ${rsync_filemgmt}:${optaplannerDocs}/${kieVersion}/optaplanner-javadoc
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/optaplanner-wb-es-docs/* ${rsync_filemgmt}:${optaplannerDocs}/${kieVersion}/optaplanner-wb-es-docs

# remove files for uploading optaplanner
rm -rf upload_binaries
rm -rf create_*_dir
rm -rf create_version

