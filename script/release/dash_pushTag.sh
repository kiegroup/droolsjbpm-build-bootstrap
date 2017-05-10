# clone the repository and the release-branch

if [ "$TARGET" == "productized" ]; then   
   git clone git@github.com:jboss-integration/dashbuilder.git --branch $RELEASE_BRANCH
else 
   git clone git@github.com:dashbuilder/dashbuilder.git --branch $RELEASE_BRANCH
fi

commitMSG="Tagging $TAG"
cd $WORKSPACE/dashbuilder
# pushes the TAG to github.com:jboss-integration or github.com:dashbuilder [IMPORTANT: "push -n" (--dryrun) should be replaced by "push" when script is ready]
if [ "$TARGET" == "productized" ]; then
   git tag -a $TAG -m "$commitMSG"
   git remote add upstream git@github.com:jboss-integration/dashbuilder.git
   git push upstream $TAG
else
   git tag -a $TAG -m "$commitMSG"
   git push origin $TAG
fi
