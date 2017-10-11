#!/bin/bash -e

# this script build the jbpm-installer
# this script should be applied for all versions Alpha, Beta, CR and Final

jbpmHtdocs=jbpm@filemgmt.jboss.org:/downloads_htdocs/jbpm/release

# download and unzip the jbpm-installer-<version>.zip
wget http://origin-repository.jboss.org/nexus/content/groups/public-jboss/org/jbpm/jbpm-installer/$version/jbpm-installer-$version.zip
unzip jbpm-installer*.zip

# modifications in build.properties
sed -i -e '/^#/!s/jBPM.version=\${snapshot.version}/jBPM.version=\${release.version}/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/jBPM.url=http.*/jBPM.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/public-jboss\/org\/drools\/droolsjbpm-bpms-distribution\/\${jBPM.version}\/droolsjbpm-bpms-distribution-$\{jBPM.version}-bin.zip/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/jBPM.console.url=http.*/jBPM.console.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/public-jboss\/org\/kie\/kie-wb\/\${jBPM.version}\/kie-wb-\${jBPM.version}-wildfly10.war/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/jBPM.casemgmt.url=https.*/jBPM.casemgmt.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/public-jboss\/org\/jbpm\/jbpm-wb-case-mgmt-showcase\/\${jBPM.version}\/jbpm-wb-case-mgmt-showcase-\${jBPM.version}-wildfly10.war/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/kie.server.url=http.*/kie.server.url=http:\/\/repository.jboss.org\/nexus\/content\/groups\/public-jboss\/org\/kie\/server\/kie-server\/${jBPM.version}\/kie-server-\${jBPM.version}-ee7.war/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/droolsjbpm.eclipse.version=\${snapshot.version}/droolsjbpm.eclipse.version=\${release.version}/g' jbpm-installer-$version/build.properties
sed -i -e '/^#/!s/droolsjbpm.eclipse.url=http.*/droolsjbpm.eclipse.url=https:\/\/repository.jboss.org\/nexus\/content\/groups\/public-jboss\/org\/drools\/org.drools.updatesite\/\${droolsjbpm.eclipse.version}\/org.drools.updatesite-\${droolsjbpm.eclipse.version}.zip/g' jbpm-installer-$version/build.properties

# add modified build.properties to jbpm-installer-<version>.zip
zip -ur jbpm-installer-$version.zip jbpm-installer-$version/build.properties

# upload installers to filemgmt.jboss.org
scp jbpm-installer-$version.zip $jbpmHtdocs/$version

