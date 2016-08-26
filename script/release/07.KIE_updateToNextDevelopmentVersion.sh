BASE_BRANCH=6.5.x
TARGET=community
TARGET_USER=kiereleaseuser
TARGET_USER_REMOTE=kie
DATE=$(date "+%Y-%m-%d")
PR_BRANCH=PR_BRANCH_$DATE

cd droolsjbpm-build-bootstrap

# change remote origin to the right URL (from https to ssh)
GIT_USER=$(git remote -v | sed '1d' | cut -d'/' -f4)
echo "GIT_USER: " $GIT_USER
git remote set-url origin git@github.com:$GIT_USER/droolsjbpm-build-bootstrap.git

git checkout $BASE_BRANCH
sh script/git-clone-others.sh -b  $BASE_BRANCH --depth 70

# checkout to PR_branch
sh script/git-all.sh checkout -b $PR_BRANCH $BASE_BRANCH


# upgrades the version to the release/tag version
sh script/release/update-version-all.sh $newVersion $TARGET

# change <version.org.uberfire>, <version.org.dashbuilder> and <version.org.jboss.errai>
sed -i "$!N;s/<version.org.uberfire>.*.<\/version.org.uberfire>/<version.org.uberfire>$UBERFIRE_VERSION<\/version.org.uberfire>/;P;D" pom.xml
sed -i "$!N;s/<version.org.dashbuilder>.*.<\/version.org.dashbuilder>/<version.org.dashbuilder>$DASHBUILDER_VERSION<\/version.org.dashbuilder>/;P;D" pom.xml

# git add and commit the version update changes 
sh script/git-all.sh add .
CommitMSG="upgraded to $newVersion"
sh script/git-all.sh commit -m "$CommitMSG"

cd $WORKSPACE

# add a remote to all repositories
REPOSITORY_LIST=$WORKSPACE/droolsjbpm-build-bootstrap/script/repository-list.txt

for REP_DIR in `cat $REPOSITORY_LIST` ; do

   if [ -d $REP_DIR ]; then
      echo " "  
      echo "==============================================================================="
      echo "Repository: $REP_DIR"
      echo "==============================================================================="
      echo " "
      
      cd $WORKSPACE/$REP_DIR
      
      # adds a remote to kiereleaseuser
      git remote add $TARGET_USER_REMOTE git@github.com:$TARGET_USER/$REP_DIR
      
      if [ "$REP_DIR" != kie-eap-modules ]; then
         SOURCE=droolsjbpm
      else
         SOURCE=jboss-integration
      fi   
      
      echo "we are at: "$REP_DIR
      echo "the new remote is: " 
      git remote -v
      git push -f $TARGET_USER_REMOTE $PR_BRANCH
      hub pull-request -m "$CommitMSG" -b $SOURCE:$BASE_BRANCH -h $TARGET_USER:$PR_BRANCH
   
      cd $WORKSPACE
   fi
done

