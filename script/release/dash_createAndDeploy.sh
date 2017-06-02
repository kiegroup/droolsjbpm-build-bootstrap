# removing dashbuilder artifacts from local maven repo (basically all possible SNAPSHOTs)
if [ -d $MAVEN_REPO_LOCAL ]; then
    rm -rf $MAVEN_REPO_LOCAL/org/dashbuilder/
fi

# clone the repository and branch
git clone git@github.com:dashbuilder/dashbuilder.git --branch $BASE_BRANCH

# checkout the release branch 
cd $WORKSPACE/dashbuilder  
git checkout -b $RELEASE_BRANCH $BASE_BRANCH

# upgrades the version to the release/tag version
sh scripts/release/update-version.sh $newVersion

# update files that are not automatically changed with the update-version.sh script
sed -i "$!N;s/<version.org.uberfire>.*.<\/version.org.uberfire>/<version.org.uberfire>$UBERFIRE_VERSION<\/version.org.uberfire>/;P;D" pom.xml   
sed -i "$!N;s/<version.org.jboss.errai>.*.<\/version.org.jboss.errai>/<version.org.jboss.errai>$ERRAI_VERSION<\/version.org.jboss.errai>/;P;D" pom.xml

# git add and commit the version update changes 
git add .
commitMSG_1="update to version "
commitMSG_2="$commitMSG_1$newVersion"
git commit -m "$commitMSG_2"

if [ "$TARGET" == "community" ]; then
   STAGING_PROFILE=15c58a1abc895b
else
   STAGING_PROFILE=15c3321d12936e
fi

# build the repos & deploy into local dir (will be later copied into staging repo)
DEPLOY_DIR=$WORKSPACE/deploy-dir
# (1) do a full build, but deploy only into local dir
# we will deploy into remote staging repo only once the whole build passed (to save time and bandwith)
mvn -B -e -U clean deploy -Dfull -Drelease -T1C -DaltDeploymentRepository=local::default::file://$DEPLOY_DIR -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx2g -Xms1g -XX:MaxPermSize=256m -XX:PermSize=128m -Xss1M" -Dgwt.compiler.localWorkers=8

# (2) upload the content to remote staging repo
cd $DEPLOY_DIR
mvn -B -e org.sonatype.plugins:nexus-staging-maven-plugin:1.6.5:deploy-staged-repository -DnexusUrl=https://repository.jboss.org/nexus -DserverId=jboss-releases-repository\
 -DrepositoryDirectory=$DEPLOY_DIR -DstagingProfileId=$STAGING_PROFILE -DstagingDescription="dashbuilder $newVersion" -DstagingProgressTimeoutMinutes=30 

cd $WORKSPACE/dashbuilder
# pushes the release-branches to rhub.com:jboss-integration or github.com:dashbuilder [IMPORTANT: "push -n" (--dryrun) should be replaced by "push" when script is finished and will be applied]
if [ "$TARGET" == "community" ]; then
   git push origin $RELEASE_BRANCH
else
   git remote add upstream git@github.com:jboss-integration/dashbuilder.git
   git push upstream $RELEASE_BRANCH
   git push upstream $BASE_BRANCH   
fi
