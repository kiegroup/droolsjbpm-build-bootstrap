def copyBinariesToFilemgmt=
"""
sh /home/jenkins/workspace/Release-6.5.x/droolsjbpm-build-bootstrap/script/dsl-scripts/08.KIE_copyBinariesToFilemgmt.sh
"""

// ******************************************************

job("KIE_copyBinariesToFilemgmt") {

  description("This job: <br> copies droolsjbpm binaries to filemgmt.jbosss.org  <br> IMPORTANT: makes only sense for community releases <br><b> Created automatically by Jenkins job DSL plugin. Do not edit manually! The changes will get lost next time the job is generated.<b>")

  label("kie-releases")

  logRotator {
    numToKeep(10)
  }

  jdk("jdk1.8")

  customWorkspace("/home/jenkins/workspace/KIE-Release-6.5.x")

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
    shell(copyBinariesToFilemgmt)
  }
}
