#!/bin/bash -e

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
kieVersion=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' bc/kiegroup_droolsjbpm_build_bootstrap/pom.xml)

filemgmtServer=drools@filemgmt-prod.jboss.org
rsync_filemgmt=drools@filemgmt-prod-sync.jboss.org
droolsDocs=docs_htdocs/drools/release
droolsHtdocs=downloads_htdocs/drools/release
uploadDir=${kieVersion}_uploadBinaries

# create directory on filemgmt-prod.jboss.org for new release
touch create_version
echo "mkdir ${droolsDocs}/${kieVersion}" > create_version
echo "mkdir ${droolsHtdocs}/${kieVersion}" >> create_version
chmod +x create_version
sftp -b create_version $filemgmtServer


# creates directory kie-api-javadoc for drools on filemgmt-prod.jboss.org
touch create_kie_api_javadoc_dir
echo "mkdir ${droolsDocs}/${kieVersion}/kie-api-javadoc" > create_kie_api_javadoc_dir
chmod +x create_kie_api_javadoc_dir
sftp -b create_kie_api_javadoc_dir $filemgmtServer

# creates directory drools-docs on filemgmt-prod.jboss.org
touch create_drools_docs_dir
echo "mkdir ${droolsDocs}/${kieVersion}/drools-docs" > create_drools_docs_dir
chmod +x create_drools_docs_dir
sftp -b create_drools_docs_dir $filemgmtServer


# upload binaries to filemgmt-prod.jboss.org
touch upload_binaries
echo "put ${uploadDir}/drools-distribution-${kieVersion}.zip ${droolsHtdocs}/${kieVersion}" > upload_binaries
echo "put ${uploadDir}/droolsjbpm-integration-distribution-${kieVersion}.zip $droolsHtdocs/${kieVersion}" >> upload_binaries
echo "put ${uploadDir}/business-central-${kieVersion}-*.war ${droolsHtdocs}/${kieVersion}" >> upload_binaries
echo "put ${uploadDir}/kie-server-distribution-${kieVersion}.zip ${droolsHtdocs}/${kieVersion}" >> upload_binaries
chmod +x upload_binaries
sftp -b upload_binaries $filemgmtServer

# upload docs to filemgmt-prod.jboss.org
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/drools-docs/* ${rsync_filemgmt}:${droolsDocs}/${kieVersion}/drools-docs
rsync -Pavqr -e 'ssh -p 2222' --protocol=28 --delete-after ${uploadDir}/kie-api-javadoc/* ${rsync_filemgmt}:${droolsDocs}/${kieVersion}/kie-api-javadoc


# make filemgmt symbolic links for drools
mkdir filemgmt_links
cd filemgmt_links

###############################################################################
# latest drools links
###############################################################################
touch ${kieVersion}
ln -s ${kieVersion} latest

echo "Uploading normal links..."
rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $rsync_filemgmt:/$droolsDocs
rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latest $rsync_filemgmt:/$droolsHtdocs

###############################################################################
# latestFinal drools links
###############################################################################
if [[ "${kieVersion}" == *Final* ]]; then
    ln -s ${kieVersion} latestFinal
    echo "Uploading Final links..."
    rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $rsync_filemgmt:/$droolsDocs
    rsync -e "ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --protocol=28 -a latestFinal $rsync_filemgmt:/$droolsHtdocs
fi

# remove files and directories for uploading drools
cd ..
rm -rf create_version
rm -rf create_*_dir
rm -rf upload_binaries
rm -rf filemgmt_links
