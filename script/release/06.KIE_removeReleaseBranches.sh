# clone the build-bootstrap that contains the other build scripts
if [ "$TARGET" == "community" ]; then 
   SOURCE=droolsjbpm
else
   SOURCE=jboss-integration
fi

if [ "$RELEASE_BRANCH" == "master" ]; then
   echo "you can't remove master branch"
   exit 1
elif [ "$RELEASE_BRANCH" == "6.5.x" ]; then
   echo "you can't remove 6.5.x branch"
   exit 1
elif [ "$RELEASE_BRANCH" == "6.4.x" ]; then
   echo "you can't remove 6.4.x branch"
   exit 1   
elif [ "$RELEASE_BRANCH" == "6.3.x" ]; then
   echo "you can't remove 6.3.x branch"
   exit 1
elif [ "$RELEASE_BRANCH" == "6.2.x" ]; then
   echo "you can't remove 6.2.x branch"
   exit 1   
fi   

git clone git@github.com:"$SOURCE"/droolsjbpm-build-bootstrap.git --branch $RELEASE_BRANCH --depth 50

# clone rest of the repos and checkout to this branch
./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $RELEASE_BRANCH --depth 50    

# remove release-branches on droolsjbpm or on jboss-integration
./droolsjbpm-build-bootstrap/script/git-all.sh push origin :$RELEASE_BRANCH 
