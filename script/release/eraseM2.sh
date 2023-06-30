#!/bin/bash -e

# removing KIE artifacts from local maven repo (basically all possible SNAPSHOTs)
# parameters: $1 = m2Dir (path to local maven repository)

if [ -d $1 ]; then
    rm -rf $1/org/dashbuilder/
    rm -rf $1/org/kie/
    rm -rf $1/org/drools/
    rm -rf $1/org/jbpm/
    rm -rf $1/org/uberfire/

fi
