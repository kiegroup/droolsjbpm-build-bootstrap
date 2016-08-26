# removing KIE artifacts from local maven repo (basically all possible SNAPSHOTs)
if [ -d $MAVEN_REPO_LOCAL ]; then
    rm -rf $MAVEN_REPO_LOCAL/org/jboss/dashboard-builder/
    rm -rf $MAVEN_REPO_LOCAL/org/kie/
    rm -rf $MAVEN_REPO_LOCAL/org/drools/
    rm -rf $MAVEN_REPO_LOCAL/org/jbpm/
    rm -rf $MAVEN_REPO_LOCAL/org/optaplanner/
    rm -rf $MAVEN_REPO_LOCAL/org/guvnor/
    
fi

# removes all created /tmp/ files by the user
find /tmp -maxdepth 1 -user `whoami` -exec rm -rf {} \;

cd droolsjbpm-build-bootstrap

# change remote origin to the right URL (from https to ssh)
GIT_USER=$(git remote -v | sed '1d' | cut -d'/' -f4)
echo "GIT_USEER: " $GIT_USER
git remote set-url origin git@github.com:$GIT_USER/droolsjbpm-build-bootstrap.git

git checkout 6.5.x
sh script/git-clone-others.sh -b 6.5.x --depth 70
