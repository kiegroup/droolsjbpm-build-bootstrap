/**
 * Builds the downstream
 * @param projectLines a collection of items following the pattern PROJECT_GROUP/PROJECT_NAME, for example kiegroup/drools
 */
def downstreamBuild(def projectLines) {
    def lastLine = projectLines.get(projectLines.size() - 1)

    println "Downstream building ${lastLine} project"
    upstreamBuild(projectLines, lastLine)
}

/**
 * Builds the upstream for an specific project
 * @param projectLines a collection of items following the pattern PROJECT_GROUP/PROJECT_NAME, for example kiegroup/drools
 * @param currentProject the project to build the stream from, like kiegroup/drools
 */
def upstreamBuild(def projectLines, String currentProject) {
    println "Upstream building ${currentProject} project"

    // Build project tree from currentProject node
    for (i = 0; currentProject != projectLines.get(i); i++) {
        buildProject(projectLines.get(i))
    }

    buildProject(currentProject)
}

/**
 *
 * @param project a string following the pattern PROJECT_GROUP/PROJECT_NAME, for example kiegroup/drools
 */
def buildProject(String project) {
    def projectGroup = project.split("\\/")[0]
    def projectName = project.split("\\/")[1]
    println "Buiding ${projectGroup}/${projectName}"

    sh "mkdir ${projectGroup}_${projectName}"
    sh "cd ${projectGroup}_${projectName}"
    githubscm.checkoutIfExists(projectName, "$CHANGE_AUTHOR", "$CHANGE_BRANCH", projectGroup, "$CHANGE_TARGET")
    maven.runMavenWithSubmarineSettings('clean install', true)
    sh ".."
}

/**
 *
 * @param projectUrl the github project url
 */
def getProject(String projectUrl) {
    return (projectUrl =~ /((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?(github.com\\/))([\w\.@\:\/\-~]+)(\.git)(\/)?/)[0][8]
}

return this;
