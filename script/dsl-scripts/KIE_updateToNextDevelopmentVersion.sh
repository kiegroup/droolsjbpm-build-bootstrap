def updateVersions=
"""
sh /home/jenkins/workspace/Release-6.5.x/droolsjbpm-build-bootstrap/script/dsl-scripts/07.KIE_updateToNextDevelopmentVersion.sh
"""

// ******************************************************

job("KIE_updateToNextDevelopmentVersion") {

  description("This job: <br> updates the KIE repositories to a new developmenmt version <br> for 6.4.x, 6.5.x or 7.0.x branches <br> IMPORTANT: Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.")
 
  parameters {
    stringParam("newVersion", "6.5.1", "Edit the new KIE development version")
    stringParam("UBERFIRE_VERSION", "0.9.1", "Edit the new development version for Uberfire/Uberfire-extensions")
    stringParam("DASHBUILDER_VERSION", "0.5.1", "Edit the new development version for dashbuilder")
  }

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
    shell(updateVersions)
  }
}
