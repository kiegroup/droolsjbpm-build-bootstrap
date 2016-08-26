# removes kie.properties if it exists
file="kie.properties"
if [ -f "$file" ]; then
   echo "$file found."
   rm $file
fi

# fetch the <version.org.kie> from kie-parent-metadata pom.xml and set it on parameter KIE_VERSION
KIE_VERSION=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -n -e 's/<version.org.kie>\(.*\)<\/version.org.kie>/\1/p' droolsjbpm-build-bootstrap/pom.xml)

# creates a properties file to pass variables and moves it to the root directory
echo KIE_VERSION=$KIE_VERSION > kie.properties
echo TARGET=$TARGET >> kie.properties

# build release branches
if [ "$TARGET" == "community" ]; then 
   DEPLOY_DIR=$WORKSPACE/KIE_Deploy_dir_community_6.5.x
   # (1) do a full build, but deploy only into local dir
   # we will deploy into remote staging repo only once the whole build passed (to save time and bandwith)   
   ./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -Dfull -Drelease -T1C -DaltDeploymentRepository=local::default::file://$DEPLOY_DIR -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx4g -Xms1g -XX:MaxPermSize=256m -XX:PermSize=128m -Xss1M" -Dgwt.compiler.localWorkers=3
  
else
   DEPLOY_DIR=$WORKSPACE/KIE_Deploy_dir_prod_6.5.x
   # (1) do a full build with prod look & feel (-Dproductized), but deploy only into local dir
   # we will deploy into remote staging repo only once the whole build passed (to save time and bandwith)   
   ./droolsjbpm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -Dfull -Dproductized -Drelease -T1C -DaltDeploymentRepository=local::default::file://$DEPLOY_DIR -Dmaven.test.failure.ignore=true\
 -Dgwt.memory.settings="-Xmx4g -Xms1g -XX:MaxPermSize=256m -XX:PermSize=128m -Xss1M" -Dgwt.compiler.localWorkers=3

fi
