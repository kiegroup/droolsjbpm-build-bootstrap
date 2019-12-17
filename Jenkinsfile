@Library('jenkins-pipeline-shared-libraries')_

pipeline {
    agent {
        label 'kie-rhel7'
    }
    tools {
        maven 'kie-maven-3.5.4'
        jdk 'kie-jdk1.8'
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        timeout(time: 300, unit: 'MINUTES')
    }
    stages {
        stage('Initialize') {
            steps {
                sh 'printenv'

            }
        }

        stage('Upstream Build') {
            steps {
                script {
                    configFileProvider([configFile(fileId: 'be8694cf-6f0f-443f-8b8a-6464849100bf', variable: 'TREE_FILE_PATH')]) {
                        def filePath = readFile "${env.TREE_FILE_PATH}"
                        treebuild.upstreamBuild(filePath.readLines(), treebuild.getProject(env.GIT_URL))
                    }
                }
            }
        }
        stage('Downstream Build') {
            steps {
                script {
                    configFileProvider([configFile(fileId: 'be8694cf-6f0f-443f-8b8a-6464849100bf', variable: 'TREE_FILE_PATH')]) {
                        def filePath = readFile "${env.TREE_FILE_PATH}"
                        treebuild.downstreamBuild(filePath.readLines())
                    }
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