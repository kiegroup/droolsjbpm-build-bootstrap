BASE_BRANCH=6.5.x
TARGET=community
TARGET_USER=kiereleaseuser
TARGET_USER_REMOTE=kie
DATE=$(date "+%Y-%m-%d")
PR_BRANCH=PR_BRANCH_$DATE

# clone droolsjbm-build-bootstrap branch from droolsjbpm
git clone git@github.com:droolsjbpm/droolsjbpm-build-bootstrap.git --branch $BASE_BRANCH

# clone rest of the repos
./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $BASE_BRANCH --depth 70

# checkout to PR_branch
./droolsjbpm-build-bootstrap/script/git-all.sh checkout -b $PR_BRANCH $BASE_BRANCH

# add a remote to all repositories
REPOSITORY_LIST=$WORKSPACE/droolsjbpm-build-bootstrap/script/repository-list.txt

for REP_DIR in `cat $REPOSITORY_LIST` ; do

   if [ -d "$REP_DIR" ]; then
   
      echo ""
      echo "==============================================================================="
      echo "Repository: $REP_DIR"
      echo "==============================================================================="
      echo ""
      
      cd $WORKSPACE/$REP_DIR
      git remote add $TARGET_USER_REMOTE git@github.com:$TARGET_USER/$REP_DIR
      cd $WORKSPACE
      
   fi
   
done


# upgrades the version to the release/tag version
./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $newVersion $TARGET

# update kie-parent-metadata
cd $WORKSPACE/droolsjbpm-build-bootstrap/

# change <version.org.uberfire>, <version.org.dashbuilder> and <version.org.jboss.errai>
sed -i "$!N;s/<version.org.uberfire>.*.<\/version.org.uberfire>/<version.org.uberfire>$UBERFIRE_VERSION<\/version.org.uberfire>/;P;D" pom.xml
sed -i "$!N;s/<version.org.dashbuilder>.*.<\/version.org.dashbuilder>/<version.org.dashbuilder>$DASHBUILDER_VERSION<\/version.org.dashbuilder>/;P;D" pom.xml

cd $WORKSPACE

# git add and commit the version update changes 
./droolsjbpm-build-bootstrap/script/git-all.sh add .
CommitMSG="upgraded to $newVersion"
./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "$CommitMSG"

 
# Raise a PR
REPOSITORY_LIST=$WORKSPACE/droolsjbpm-build-bootstrap/script/repository-list.txt

for REP_DIR in `cat $REPOSITORY_LIST` ; do

   if [ -d $REP_DIR ]; then
      echo " "  
      echo "==============================================================================="
      echo "Repository: $REP_DIR"
      echo "==============================================================================="
      echo " "
      
      cd $WORKSPACE/$REP_DIR
      
      if [ "$REP_DIR" != kie-eap-modules ]; then
         SOURCE=droolsjbpm
      else
         SOURCE=jboss-integration
      fi   
      
      git push -f $TARGET_USER_REMOTE $PR_BRANCH
      hub pull-request -m "$CommitMSG" -b $SOURCE:$BASE_BRANCH -h $TARGET_USER:$PR_BRANCH
   
      cd $WORKSPACE
   fi
done

