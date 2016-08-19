BASE_BRANCH=6.4.x

# clone the build-bootstrap that contains the other build scripts
if [ "$SOURCE" == "community-branch" ]; then
     
   # clone droolsjbm-build-bootstrap branch from droolsjbpm
   git clone git@github.com:droolsjbpm/droolsjbpm-build-bootstrap.git --branch $BASE_BRANCH

   # clone rest of the repos
   ./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $BASE_BRANCH --depth 70
   
   # checkout to local release names
   ./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $RELEASE_BRANCH $BASE_BRANCH
   
   # add new remote pointing to jboss-integration
   ./droolsjbpm-build-bootstrap/script/git-add-remote-jboss-integration.sh

fi

if [ "$SOURCE" == "community-tag" ]; then

   # clone droolsjbm-build-bootstrap branch from droolsjbpm
   git clone git@github.com:droolsjbpm/droolsjbpm-build-bootstrap.git --branch $BASE_BRANCH

   # clone rest of the repos
   ./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $BASE_BRANCH --depth 70

   # add new remote pointing to jboss-integration
   ./droolsjbpm-build-bootstrap/script/git-add-remote-jboss-integration.sh
   
   # get the tags of community
   ./droolsjbpm-build-bootstrap/script/git-all.sh fetch --tags origin
   
   # checkout to local release names
   ./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $RELEASE_BRANCH $TAG


fi
   
if [ "$SOURCE" == "production-tag" ]; then

   # clone droolsjbm-build-bootstrap branch from jboss-integration
   git clone git@github.com:jboss-integration/droolsjbpm-build-bootstrap.git --branch $BASE_BRANCH

   # clone rest of the repos
   ./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $BASE_BRANCH --depth 70

   # add new remote pointing to jboss-integration
   ./droolsjbpm-build-bootstrap/script/git-add-remote-jboss-integration.sh
   
   # get the tags of jboss-integration
   ./droolsjbpm-build-bootstrap/script/git-all.sh fetch --tags jboss-integration
   
   # checkout to local release names
   ./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $RELEASE_BRANCH $TAG


fi

# upgrades the version to the release/tag version
./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $RELEASE_VERSION $TARGET

# update kie-parent-metadata
cd droolsjbpm-build-bootstrap/

# change <version.org.uberfire>, <version.org.dashbuilder> and <version.org.jboss.errai>
sed -i "$!N;s/<version.org.uberfire>.*.<\/version.org.uberfire>/<version.org.uberfire>$UBERFIRE_VERSION<\/version.org.uberfire>/;P;D" pom.xml
sed -i "$!N;s/<version.org.dashbuilder>.*.<\/version.org.dashbuilder>/<version.org.dashbuilder>$DASHBUILDER_VERSION<\/version.org.dashbuilder>/;P;D" pom.xml

cd ..

# git add and commit the version update changes 
./droolsjbpm-build-bootstrap/script/git-all.sh add .
CommitMSG_1="upgraded to "
CommitMSG_2="$CommitMSG_1$RELEASE_VERSION"
./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "$CommitMSG_2"

# pushes the local release branches to droolsjbpm or to jboss-integration [IMPORTANT: "push -n" (--dryrun) should be replaced by "push" when script will be in production]
if [ "$TARGET" == "community" ]; then
  ./droolsjbpm-build-bootstrap/script/git-all.sh push  origin $RELEASE_BRANCH
else
  ./droolsjbpm-build-bootstrap/script/git-all.sh push  jboss-integration $RELEASE_BRANCH
  ./droolsjbpm-build-bootstrap/script/git-all.sh push  jboss-integration $BASE_BRANCH
fi
