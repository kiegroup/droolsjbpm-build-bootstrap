@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'kie-rhel7-priority'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 1202, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'printenv'

            }
        }
        stage('Downstream Build') {
            final REPOSITORY_LIST_FILE = "./script/repository-list.txt"
            final SETTINGS_XML_ID = "771ff52a-a8b4-40e6-9b22-d54c7314aa1e"
            configFileProvider([configFile(fileId: SETTINGS_XML_ID, variable: 'MAVEN_SETTINGS_XML_DOWNSTREAM')]) {
                treebuild.downstreamBuild(['kiegroup/lienzo-core', 'kiegroup/lienzo-tests', 'kiegroup/droolsjbpm-build-bootstrap'], "${SETTINGS_XML_ID}", 'clean', true)
            }
        }
    }
    post {
        always {
            script {
                util.printGitInformationReport()
            }
        }
        cleanup {
            cleanWs()
        }
    }
}
