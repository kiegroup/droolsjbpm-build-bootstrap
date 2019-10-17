#!/bin/bash -e

# pushes the tag to github for community releases

# create a tag
commitMsg="Tagging $kieVersion"
./droolsjbpm-build-bootstrap/script/git-all.sh tag -a $kieVersion -m "$commitMsg"

# pushes tag to github ¡/kiegroup
./droolsjbpm-build-bootstrap/script/git-all.sh push origin $kieVersion