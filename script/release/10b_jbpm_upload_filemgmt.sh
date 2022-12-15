#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' bc/kiegroup_droolsjbpm_build_bootstrap/pom.xml)

filemgmtServer=jbpm@filemgmt-prod.jboss.org
rsync_filemgmt=jbpm@filemgmt-prod-sync.jboss.org
jbpmDocs=docs_htdocs/jbpm/release
jbpmHtdocs=downloads_htdocs/jbpm/release
uploadDir=${kieVersion}_uploadBinaries

# create directory on filemgmt-prod.jboss.org for new release
touch create_version
echo "mkdir ${jbpmDocs}/${kieVersion}" > create_version
echo "mkdir ${jbpmHtdocs}/${kieVersion}" >> create_version
chmod +x create_version
sftp -b create_version $filemgmtServer

# create directory on filemgmt-prod.jboss.org for service-repository
touch create_service_repository_dir
echo "mkdir ${jbpmHtdocs}/${kieVersion}/service-repository" > create_service_repository_dir
chmod +x create_service_repository_dir
sftp -b create_service_repository_dir $filemgmtServer

# create directory on filemgmt-prod.jboss.org for docs
touch create_jbpm_docs_dir
echo "mkdir ${jbpmDocs}/${kieVersion}/jbpm-docs" > create_jbpm_docs_dir
chmod +x create_jbpm_docs_dir
sftp -b create_jbpm_docs_dir $filemgmtServer

# upload binaries to filemgmt-prod.jboss.org
touch upload_binaries
echo "put ${uploadDir}/jbpm-${kieVersion}-bin.zip ${jbpmHtdocs}/${kieVersion}" > upload_binaries
echo "put ${uploadDir}/jbpm-${kieVersion}-examples.zip ${jbpmHtdocs}/${kieVersion}" >> upload_binaries
echo "put ${uploadDir}/jbpm-server-${kieVersion}-dist.zip ${jbpmHtdocs}/${kieVersion}" >> upload_binaries

# uploads jbpm -installers to filemgt.jboss.org
echo "put jbpm-installer-${kieVersion}.zip ${jbpmHtdocs}/${kieVersion}" >> upload_binaries
echo "put jbpm-installer-full-${kieVersion}.zip ${jbpmHtdocs}/${kieVersion}" >> upload_binaries
chmod +x upload_binaries
sftp -b upload_binaries $filemgmtServer

# upload docs to filemgmt-prod.jboss.org
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/jbpm-docs/* ${rsync_filemgmt}:${jbpmDocs}/${kieVersion}/jbpm-docs
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/service-repository/* ${rsync_filemgmt}:${jbpmDocs}/${kieVersion}/service-repository

# make filemgmt symbolic links for jbpm
mkdir filemgmt_links
cd filemgmt_links

###############################################################################
# latest jbpm links
###############################################################################
touch ${kieVersion}
ln -s ${kieVersion} latest

echo "Uploading normal links..."
rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $rsync_filemgmt:/$jbpmDocs
rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $rsync_filemgmt:/$jbpmHtdocs

###############################################################################
# latestFinal jbpm links
###############################################################################
if [[ "${kieVersion}" == *Final* ]]; then
    ln -s ${kieVersion} latestFinal
    echo "Uploading Final links..."
    rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $rsync_filemgmt:/$jbpmDocs
    rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $rsync_filemgmt:/$jbpmHtdocs
fi

# remove files and directories for uploading jbpm
cd ..
rm -rf create_version
rm -rf create_*_dir
rm -rf upload_binaries
rm -rf filemgmt_links