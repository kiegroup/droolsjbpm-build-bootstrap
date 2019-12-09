@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'kie-rhel7'
    }
    environment {
        DISABLE_AUTH = 'true'
        DB_ENGINE    = 'sqlite'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 180, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'printenv'
            }
        }
        stage('Build droolsjbpm-build-bootstrap projects') {
            steps {
                script {
                    load("$WORKSPACE/build.stages")
                }
            }
        }
    }
    post {
        unstable {
            script {
                mailer.sendEmailFailure()
            }
        }
        failure {
            script {
                mailer.sendEmailFailure()
            }
        }
        always {
            // Currently there are no tests in submarine-examples
            //junit '**/target/surefire-reports/**/*.xml'
            cleanWs()
        }
    }
}