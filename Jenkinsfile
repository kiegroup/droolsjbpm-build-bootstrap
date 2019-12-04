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
        stage('Call external groovy') {
            steps {
                script {
                    def externalCall = load("$WORKSPACE/lienzo-tests/externalCall.groovy")
                    externalCall("emingora")
                }
            }
        }
        stage('Call external pipeline.groovy1') {
            steps {
                script {
                    load("$WORKSPACE/lienzo-tests/pipeline.groovy")
                }
            }
        }
        stage('Call external pipeline.groovy2') {
            steps {
                script {
                    def pipelineGroovy = load("$WORKSPACE/lienzo-tests/pipeline.groovy")
                    pipelineGroovy()
                }
            }
        }
        stage('Call external Jenkinsfile1') {
            steps {
                script {
                    load("$WORKSPACE/lienzo-tests/Jenkinsfile")
                }
            }
        }
        stage('Call external Jenkinsfile2') {
            steps {
                script {
                    def jenkinsfile = load("$WORKSPACE/lienzo-tests/Jenkinsfile")
                    jenkinsfile()
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