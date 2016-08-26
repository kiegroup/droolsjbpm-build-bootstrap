# clone the build-bootstrap that contains the other build scripts
if [ "$TARGET" == "community" ]; then 
   SOURCE=droolsjbpm
else
   SOURCE=jboss-integration
fi

# create a tag
CommitMSG_1="Tagging "
CommitMSG_2="$CommitMSG_1$TAG_NAME"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $TAG_NAME -m "$CommitMSG_2"

# pushes tag to the SOURCE
./droolsjbpm-build-bootstrap/script/git-all.sh push origin $TAG_NAME
