@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'submarine-static || kie-rhel7'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 10, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                echo "LOG:A1-1"
                sh 'printenv'
                echo "LOG:A1-2"
            }
        }
        stage('Build droolsjbpm-build-bootstrap projects') {
            steps {
                script {
                    echo "LOG:A2-1"
                    sh "ls"
                    load("$WORKSPACE/build.stages")
                    echo "LOG:A2-2"
                    sh "pwd"
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