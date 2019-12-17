def downstreamBuild(String treeFilePath) {
    def lines = new File(treeFilePath).readLines()
    def lastLine = lines.get(lines.size() - 1)

    println "Downstream building ${lastLine} project"
    upstreamBuild(treeFilePath, lastLine)
}

def upstreamBuild(String treeFilePath, String currentProject) {
    println "Upstream building ${currentProject} project"

    def projects = new File(treeFilePath).readLines()

    // Build project tree from currentProject node
    for (i = 0; currentProject != projects.get(i); i++) {
        buildProject(projects.get(i))
    }

    buildProject(currentProject)
}

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

def getProject(String projectUrl) {
    return (projectUrl =~ /((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?(github.com\\/))([\w\.@\:\/\-~]+)(\.git)(\/)?/)[0][8]
}