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

# removes all release relevant directories from /home/jenkins/worksspace
rm -rf /home/jenkins/workspace/Deploy_dir_6.5.x
rm -rf /home/jenkins/workspace/KIE-Release-6.5.x/*

git clone git@github.com:droolsjbpm/droolsjbpm-build-bootstrap.git -b 6.5.x
cd droolsjbpm-build-bootstrap
sh script/git-clone-others.sh -b 6.5.x --depth 70
