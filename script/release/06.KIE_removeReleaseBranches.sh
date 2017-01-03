# clone the build-bootstrap that contains the other build scripts
if [ "$TARGET" == "community" ]; then 
   SOURCE=origin
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

# remove release-branches on droolsjbpm or on jboss-integration
./droolsjbpm-build-bootstrap/script/git-all.sh push $SOURCE :$RELEASE_BRANCH 
