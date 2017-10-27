#!/bin/bash -e

echo "kieVersion:" $kieVersion
echo "target" : $target

# clone the build-bootstrap that contains the other build scripts
if [ "$target" == "community" ]; then
   source=kiegroup
   remote=origin
else
   source=jboss-integration
   remote=gerrit
fi

git clone git@github.com:"$source"/droolsjbpm-build-bootstrap.git --branch $releaseBranch --depth 100

# clone rest of the repos and checkout to this branch
./droolsjbpm-build-bootstrap/script/git-clone-others.sh --branch $releaseBranch --depth 100

# add a new remote pointing to gerrit
./droolsjbpm-build-bootstrap/script/git-add-remote-gerrit.sh

# create a tag
commitMsg="Tagging $tag"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $tag -m "$commitMsg"

# pushes tag to the SOURCE
./droolsjbpm-build-bootstrap/script/git-all.sh push $remote $tag
