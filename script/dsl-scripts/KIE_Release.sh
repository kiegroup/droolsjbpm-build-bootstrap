def releasePrepare =
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/01.KIE_releasePrepare.sh
"""

def pushReleaseBranches =
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/02.KIE_pushReleaseBranches.sh
"""

def deployLocally=
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/03.KIE_deployLocally.sh
"""

def copyToNexus=
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/04.KIE_copyToNexus.sh
"""

def jbpmTestCoverageMatrix=
"""
git clone https://github.com/droolsjbpm/droolsjbpm-build-bootstrap.git -b 6.5.x
sh \$WORKSPACE/droolsjbpm-build-bootstrap/script/release/04a.KIE_jbpmTestCoverMartix.sh
"""
def apiBackwardsCompatCheck=
"""
git clone https://github.com/droolsjbpm/droolsjbpm-build-bootstrap.git -b 6.5.x
sh \$WORKSPACE/droolsjbpm-build-bootstrap/script/release/04b.KIE_apiBackwardsCompatCheck.sh
"""
def kieAllServerMatrix=
"""
git clone https://github.com/droolsjbpm/droolsjbpm-build-bootstrap.git -b 6.5.x
sh \$WORKSPACE/droolsjbpm-build-bootstrap/script/release/04c.KIE_kieAllServerMatrix.sh
"""
def kieWbSmokeTestsMatrix=
"""
git clone https://github.com/droolsjbpm/droolsjbpm-build-bootstrap.git -b 6.5.x
sh \$WORKSPACE/droolsjbpm-build-bootstrap/script/release/04d.KIE_kieWbSmokeTestsMatrix.sh
"""
def pushTags=
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/05.KIE_pushTag.sh
"""
def removeBranches=
"""
sh /home/jenkins/workspace/DSL-KIE-Release-6.5.x/script/release/06.KIE_removeReleaseBranches.sh
"""

// ****************************************************************************

job("01.releasePrepare") {

  description("This job: <br> - prepares the release, clones the right branches etc. <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")
     
  logRotator {
    numToKeep(10)
  }
 
  label("kie-releases")
  
  jdk("jdk1.8") 
 
  customWorkspace("/home/jenkins/workspace/KIE-Release-6.5.x")

  wrappers {
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }  

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }  

  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }    
    shell(releasePrepare)
  }
}

// **************************************************************************

job("02.pushReleaseBranches") {

  description("This job: <br> checksout the right source- upgrades the version in poms <br> - modifies the kie-parent-metadata pom <br> - pushes the generated release branches to droolsjbpm <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")
  
  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> ******************************************************** <br> ")
    choiceParam("SOURCE", ["community-branch", "community-tag", "production-tag"], " please select the source of this release <br> or it is the 6.5.x branch ( <b> community-branch </b> ) <br> or a community tag ( <b> community-tag </b> ) <br> or a productization tag ( <b> production-tag </b> ) <br> ******************************************************** <br> ")
    stringParam("TAG", "6.5.0.Final", "if you selected as <b> SOURCE=community-tag </b> or <b> SOURCE=production-tag </b> please edit the name of the tag <br> if selected as <b> SOURCE=community-branch </b> the parameter <b> TAG </b> will be ignored <br> The tag should typically look like <b> 6.5.0.Final </b> for <b> community </b> or <b> sync-6.5.x-2016.08.07  </b> for <b> productization </b> <br> ******************************************************** <br> ")
    stringParam("RELEASE_VERSION", "6.5.0.Final", "please edit the version for this release <br> The <b> RELEASE_VERSION </b> should typically look like <b> 6.5.0.Final </b> for <b> community </b> or <b> 6.5.0.20160805-productization </b> for <b> productization </b> <br>******************************************************** <br> ")
    stringParam("RELEASE_BRANCH", "r6.5.0.Final", "please edit the name of the release branch <br> i.e. typically <b> r6.5.0.Final </b> for <b> community </b>or <b> bsync-6.5.x-2016.08.05  </b> for <b> productization </b> <br> ******************************************************** <br> ")
    stringParam("UBERFIRE_VERSION", "0.9.0.Final", "please edit the right version to use of uberfire/uberfire-extensions <br> The tag should typically look like <b> 0.9.0.Final </b> for <b> community </b> or <b> 0.9.0.20160805-productization </b> for <b> productization </b> <br> ******************************************************** <br> ")
    stringParam("DASHBUILDER_VERSION", "0.5.0.Final", "please edit the right version to use of dashbuilder <br> The tag should typically look like <b> 0.5.0.Final </b> for <b> community </b> or <b> 0.5.0.20160805-productization </b> for <b> productization </b> <br> ******************************************************** <br> ") 
  };
  
  label("kie-releases")

  logRotator {
    numToKeep(10)
  }
 
  jdk("jdk1.8") 

  customWorkspace("/home/jenkins/workspace/KIE-Release-6.5.x")
  
  wrappers {
    timestamps()
    colorizeOutput()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }  
  
  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }
 
  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }    
    shell(pushReleaseBranches)
  }
}

// **************************************************************************************

job("03.buildDeployLocally") {

  description("This job: <br> - builds all repositories and deploys them locally <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")
  
  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> ******************************************************** <br> ")
    stringParam("RELEASE_BRANCH", "r6.5.0.Final", "please edit the name of the release branch <br> i.e. typically <b> r6.5.0.Final </b> for <b> community </b>or <b> bsync-6.5.x-2016.08.05  </b> for <b> productization </b> <br> ******************************************************** <br> ")
  };
  
  label("kie-releases")

  logRotator {
    numToKeep(10)
  }

  jdk("jdk1.8") 
  
  customWorkspace("/home/jenkins/workspace/KIE-Release-6.5.x")
 
  publishers {
    archiveJunit("**/TEST-*.xml")
  }

  wrappers {
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }  

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }  
 
  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }    
    shell(deployLocally)
  }
}

// ********************************************************************************

job("04.copyToNexus") {

  description("This job: <br> - copies binaries from local dir to Nexus <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> ******************************************************** <br> ")
  };

  label("kie-releases")
  
  logRotator {
    numToKeep(10)
  }

  jdk("jdk1.8")

  customWorkspace("/home/jenkins/workspace/KIE-Release-6.5.x")

  wrappers {
    timestamps()
    colorizeOutput()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }

  publishers{
    downstreamParameterized {
      trigger("04a.allJbpmTestCoverageMatrix, 04b.apiBackwardsCompatCheck, 04c.kieAllServerMatrix, 04d.kieWbSmokeTestsMatrix") {
        condition("SUCCESS")
        parameters {
          propertiesFile("/home/jenkins/workspace/KIE-Release-6.5.x/kie.properties", true)
        }
      }
    }
  }

  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }
    shell(copyToNexus)
  }


}

// **************************************************************************************

matrixJob("04a.allJbpmTestCoverageMatrix") {

  description("This job: <br> - Test coverage Matrix for jbpm <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")
  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> Version to test. Will be supplied by the parent job. <br> ******************************************************** <br> ")
    stringParam("KIE_VERSION", "6.5.0.Final", "please edit the version of the KIE release <br> i.e. typically <b> 6.5.0.Final </b> for <b> community </b>or <b> 6.5.0.20160805-productized </b> for <b> productization </b> <br> Version to test. Will be supplied by the parent job. <br> ******************************************************** <br> ")
  };

  axes {
    jdk("jdk1.6", "jdk1.7", "jdk1.8")
  }              

  logRotator {
    numToKeep(10)
  }

  label("linux && mem4g")
  
  wrappers {
    timestamps()
    colorizeOutput()
    preBuildCleanup()
   }

  publishers {
    archiveJunit("**/TEST-*.xml")
    mailer('mbiarnes@redhat.com', false, false)
  }
  
  steps {
    shell(jbpmTestCoverageMatrix)
    maven{
      mavenInstallation("apache-maven-3.2.3")
      goals("clean verify -e -B -Dmaven.test.failure.ignore=true -Dintegration-tests")
      rootPOM("jbpm-test-coverage/pom.xml")
      mavenOpts("-Xmx3g")
      providedSettings("settings-consume-internal-kie-builds")
    }  
  }  
}

// ***************************************************************************************

job("04b.apiBackwardsCompatCheck") {
  description("This job: <br> - kie-releases backwards compatibility check <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "<br> ******************************************************** <br> ")
    stringParam("KIE_VERSION", "6.5.0.Final", "the KIE_VERSION will be supplied by parent job")
  };
  
  label("linux && mem4g")

  logRotator {
    numToKeep(10)
  }
  
  jdk("jdk1.8")
  
  wrappers {
    timestamps()
    colorizeOutput()
    preBuildCleanup()
   }

  configure { project -> 
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }
  
  publishers {
    archiveArtifacts{
      pattern("kie-api/target/site/*")
      defaultExcludes(true)
    }  
    mailer('mbiarnes@redhat.com', false, false)
  }
  
  steps {
    shell(apiBackwardsCompatCheck)
    maven{
      mavenInstallation("apache-maven-3.2.3")
      goals("clean verify -e -B -Dmaven.test.failure.ignore=true -Papi-compatibility-check")
      rootPOM("kie-api/pom.xml")
      providedSettings("settings-consume-internal-kie-builds")
    }  
  }  
}

// **********************************************************************************

matrixJob("04c.kieAllServerMatrix") {
  description("This job: <br> - Runs the KIE Server integration tests on mutiple supported containers and JDKs <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated. ")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "<br> ******************************************************** <br> ")
    stringParam("KIE_VERSION", "6.5.0.Final", "the KIE_VERSION will be supplied by parent job")
  };
  
  axes {
    jdk("jdk1.6", "jdk1.7", "jdk1.8")
    text("container", "tomcat7x", "tomcat8x", "wildfly82x", "eap64x")
    labelExpression("label_exp", "linux && mem4g")
  }              
  
  childCustomWorkspace("\${SHORT_COMBINATION}")

  combinationFilter('(jdk == "jdk1.7") || (jdk == "jdk1.8") || (container == "tomcat7x" || container ==  "eap64x")')

  runSequentially()
  
  touchStoneFilter('jdk == "jdk1.7" && container == "eap64x"', continueOnUnstable = true)
  

  logRotator {
    numToKeep(10)
  }
  
  wrappers {
    timeout {
      absolute(120)
    }
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    configFiles {
      mavenSettings("settings-consume-internal-kie-builds"){
        variable("SETIINGS_XML_FILE")      
      }  
    }    
   }
  

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }

  publishers {
    archiveJunit("**/target/failsafe-reports/TEST-*.xml")
    mailer('mbiarnes@redhat.com', false, false)
  }
  
  steps {
    shell(kieAllServerMatrix)
    maven{
      mavenInstallation("apache-maven-3.2.3")
      goals("-B -U -e -fae clean verify -P\$container")
      rootPOM("kie-server-parent/kie-server-tests/pom.xml")
      properties("kie.server.testing.kjars.build.settings.xml":"\$SETTINGS_XML_FILE")
      properties("maven.test.failure.ignore": true)
      properties("deployment.timeout.millis":"240000")
      properties("container.startstop.timeout.millis":"240000")
      properties("eap64x.download.url":"http://download.devel.redhat.com/released/JBEAP-6/6.4.4/jboss-eap-6.4.4-full-build.zip")
      mavenOpts("-XX:MaxPermSize=512m -Xms1024m -Xmx1536m")
      providedSettings("settings-consume-internal-kie-builds")
    }  
  }  
}

// ****************************************************************************************************

matrixJob("04d.kieWbSmokeTestsMatrix") {
  description("This job: <br> - Runs the smoke tests on KIE <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated. ")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "<br> ******************************************************** <br> ")
    stringParam("KIE_VERSION", "6.5.0.Final", "the KIE_VERSION will be supplied by parent job")
  };
  
  axes {
    jdk("jdk1.6", "jdk1.7", "jdk1.8")
    text("container", "tomcat7", "tomcat8", "eap64")
    text("war", "kie-wb", "kie-drools-wb")
    labelExpression("label_exp", "linux && mem4g && gui-testing")
  }              
  
  childCustomWorkspace("\${SHORT_COMBINATION}")

  combinationFilter('jdk == "jdk1.7" || jdk == "jdk1.8" || container == "tomcat7" || container ==  "eap64"')

  runSequentially()
  
  properties {
    rebuild {
      autoRebuild()
    }
  } 

  logRotator {
    numToKeep(10)
  }

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }
  
  wrappers {
    timeout {
      absolute(120)
    }
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    xvnc {
      useXauthority(true)
    }  
   }

  publishers {
    archiveJunit("**/target/failsafe-reports/TEST-*.xml")
    mailer('mbiarnes@redhat.com', false, false)
  }
  
  steps {
    shell(kieWbSmokeTestsMatrix)
    maven{
      mavenInstallation("apache-maven-3.2.3")
      goals("-B -e -fae clean verify -P\$container,\$war,selenium -D\$TARGET")
      rootPOM("kie-wb-smoke-tests/pom.xml")
      properties("jdk.min.version": "1.6")
      properties("maven.test.failure.ignore":true)
      properties("deployment.timeout.millis":"240000")
      properties("container.startstop.timeout.millis":"240000")
      properties("webdriver.firefox.bin":"/opt/tools/firefox-38esr/firefox-bin")
      properties("eap64.download.url":"http://download.devel.redhat.com/released/JBEAP-6/6.4.5/jboss-eap-6.4.5-full-build.zip")
      mavenOpts("-XX:MaxPermSize=512m -Xms1024m -Xmx1536m")
      providedSettings("settings-consume-internal-kie-builds")
    }  
  }  
}

// ************************************************************************************************

job("05.pushTags") {

  description("This job: <br> creates and pushes the tags for <br> community (droolsjbpm) or product (jboss-integration) <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> ******************************************************** <br> ")
    stringParam("RELEASE_BRANCH", "r6.5.0.Final", "please edit the name of the release branch <br> i.e. typically <b> r6.5.0.Final </b> for <b> community </b>or <b> bsync-6.5.x-2016.08.05  </b> for <b> productization </b> <br> ******************************************************** <br> ")
    stringParam("TAG_NAME", "Please enter the name of the tag", "The tag should typically look like <b> 6.5.0.Final </b> for <b> community </b> or <b> sync-6.5.0.2016.08.05 </b> for <b> productization </b> <br> ******************************************************** <br> ")
  };

  label("kie-releases")

  logRotator {
    numToKeep(10)
  }

  jdk("jdk1.8")

  wrappers {
    timeout {
      absolute(30)
    }
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }

  publishers {
    mailer('mbiarnes@redhat.com', false, false)
  }

  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }
    shell(pushTags)
  }
}

// ***********************************************************************************

job("05.removeReleaseBranches") {

  description("This job: <br> creates and pushes the tags for <br> community (droolsjbpm) or product (jboss-integration) <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")

  parameters {
    choiceParam("TARGET", ["community", "productized"], "please select if this release is for community <b> community </b> or <br> if it is for building a productization tag <b>productized <br> ******************************************************** <br> ")
    stringParam("RELEASE_BRANCH", "r6.5.0.Final", "please edit the name of the release branch <br> i.e. typically <b> r6.5.0.Final </b> for <b> community </b>or <b> bsync-6.5.x-2016.08.05  </b> for <b> productization </b> <br> ******************************************************** <br> ")
  };

  label("kie-releases")

  logRotator {
    numToKeep(10)
  }

  jdk("jdk1.8")

  wrappers {
    timeout {
      absolute(30)
    }
    timestamps()
    colorizeOutput()
    preBuildCleanup()
    toolenv("APACHE_MAVEN_3_2_3", "JDK1_8")
  }

  configure { project ->
    project / 'buildWrappers' << 'org.jenkinsci.plugins.proccleaner.PreBuildCleanup' {
      cleaner(class: 'org.jenkinsci.plugins.proccleaner.PsCleaner') {
        killerType 'org.jenkinsci.plugins.proccleaner.PsAllKiller'
        killer(class: 'org.jenkinsci.plugins.proccleaner.PsAllKiller')
        username 'jenkins'
      }
    }
  }

  publishers {
    mailer('mbiarnes@redhat.com', false, false)
  }

  steps {
    environmentVariables {
        envs(MAVEN_OPTS :"-Xms2g -Xmx3g -XX:MaxPermSize=512m", MAVEN_HOME: "\$APACHE_MAVEN_3_2_3_HOME", MAVEN_REPO_LOCAL: "/home/jenkins/.m2/repository", PATH :"\$MAVEN_HOME/bin:\$PATH")
    }
    shell(removeBranches)
  }
}

// *****
// *****

nestedView("Releases") {
    views {
        listView("KIE-6.5.x") {
            jobs {
                name("01.releasePrepare")
                name("02.pushReleaseBranches")
                name("03.buildDeployLocally")
                name("04.copyToNexus")
                name("04a.allJbpmTestCoverageMatrix")
                name("04b.apiBackwardsCompatCheck")
                name("04c.kieAllServerMatrix")
                name("04d.kieWbSmokeTestsMatrix")
                name("05.pushTags")
                name("05.removeReleaseBranches")
            }
            columns {
                status()
                weather()
                name()
                lastSuccess()
                lastFailure()
            }
        }
    }
}
