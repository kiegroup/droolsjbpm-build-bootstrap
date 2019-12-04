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
                sh 'printenv'
            }
        }
        stage('Build lienzo-tests') {
            steps {
                script {
                    def externalCall = load("$WORKSPACE/lienzo-tests/externalCall.groovy")
                    externalCall("emingora")
                }
            }
        }
        stage('Build kie-parent') {
            steps {
                script {
                    maven.runMavenWithSubmarineSettings('clean install -DskipTests', false)
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