echo "KIE version" $KIE_VERSION

if [ "$TARGET" == "community" ]; then 
   STAGING_REP=kie-group
else
   STAGING_REP=kie-internal-group
fi

wget -q https://repository.jboss.org/nexus/content/groups/$STAGING_REP/org/kie/kie-api-parent/$KIE_VERSION/kie-api-parent-$KIE_VERSION-project-sources.tar.gz -O sources.tar.gz

tar xzf sources.tar.gz
mv kie-api-parent-$KIE_VERSION/* .
rmdir kie-api-parent-$KIE_VERSION
