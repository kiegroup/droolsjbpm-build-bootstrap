def repoFile = readFileFromWorkspace("./script/repository-list.txt")
def repoList = repoFile.split()

for (repo in repoList) {

    def jobName = "srcclr-scan-${repo}"

    job(jobName) {

        description("Job responsible for SourceClear verification of ${repo}")

        parameters {
            choiceParam('SCAN_TYPE', ['scm', 'binary'])
            stringParam('SRCCLR_INVOKER_REPO_URL','')
            stringParam('URL','')
            stringParam('VERSION', '')
            stringParam('PACKAGE','')
            stringParam('NAME', '')
            stringParam('MVNPARAMS', '')
            choiceParam('PROCESSOR_TYPE', ['cve', 'cvss'])
            booleanParam('RECURSIVE', false)
            booleanParam('DEBUGGING', false)
            booleanParam('TRACING', false)
            stringParam('SCMVERSION', '')
            stringParam('THRESHOLD', '1','Threshold from 1 to 10 for cvss processor')
        }


        environmentVariables{
            groovy('''
          def map = [:]
          map.put("RECURSE", Boolean.valueOf("${RECURSIVE}") ? "--recursive" : "")
          map.put("DEBUG", Boolean.valueOf("${DEBUGGING}") ? "-d" : "");
          map.put("TRACE", Boolean.valueOf("${TRACING}") ? "--trace" : "")
          map.put("MVNPARAMETER", "${MVNPARAMS}" !="" ? "--maven-param=${MVNPARAMS}":"")
          map.put("SCMVERSIONPARAM", "${SCAN_TYPE}" == "scm" ? " --ref=${SCMVERSION}":"")
          return map
        ''')
            sandbox()
        }


        label("kie-rhel7")

        wrappers {
            credentialsBinding {
                string("SRCCLR_API_TOKEN", "SRCCLR_API_TOKEN")
            }
        }

        scm {
            git {
                remote {
                    name('origin')
                    url("${SRCCLR_INVOKER_REPO_URL}")
                }
                branch('master')
            }
        }
        steps {
            maven {
                mavenInstallation("kie-maven-3.5.4")
                goals('-Pjenkins test -Dmaven.buildNumber.skip=true -DargLine="-Dsourceclear=\"\${DEBUG} \${TRACE} --processor=\${PROCESSOR_TYPE} --product-version=\${VERSION} --package=\${PACKAGE} --product=\"\${NAME}\" --threshold=\${THRESHOLD} \${SCAN_TYPE} --url=\${URL} \${MVNPARAMETER} \${SCMVERSIONPARAM} \${RECURSE}\""')
            }
        }

        publishers {
            archiveJunit("**/target/*-reports/*.xml") {
                retainLongStdout()
                healthScaleFactor(1.0)
                allowEmptyResults()
            }
            archiveArtifacts {
                pattern("**/target/vulnerabilityLogFile.txt")
                allowEmpty()
            }
        }
    }
}
