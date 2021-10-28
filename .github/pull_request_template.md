**Thank you for submitting this pull request**

**JIRA**: _(please edit the JIRA link if it exists)_ 

[link](https://www.example.com)

**referenced Pull Requests**: _(please edit the URLs of referenced pullrequests if they exist)_

* paste the link(s) from GitHub here
* link 2
* link 3 etc.


<details>
<summary>
How to replicate CI configuration locally?
</summary>

We do "simple" maven builds, they are just basically maven commands, but just because we have multiple repositories related between them and one change could affect several of those projects by multiple pull requests, we use [build-chain tool](https://github.com/kiegroup/github-action-build-chain) to handle cross repository builds and be sure that we always use latest version of the code for each repository.
 
[build-chain tool](https://github.com/kiegroup/github-action-build-chain) is not only a github-action tool but a CLI one, so you can reproduce almost the same build by executing it locally.
If you want to do so(for example to reproduce a CI error hard to reproduce) you can go either to the Github Actions job or to the Jenkins job and to copy/paste the details under `Printing local execution command`. You will see something like:
 
```
  [INFO]  You can copy paste the following commands to locally execute build chain tool.
  [INFO]  npm i @kie/build-chain-action@2.3.19 -g
  [INFO]  build-chain-action -df "https://raw.githubusercontent.com/${GROUP}/droolsjbpm-build-bootstrap/${BRANCH:main}/.ci/pull-request-config.yaml" build pr -url https://github.com/kiegroup/appformer/pull/1208
  [WARN]  Remember you need Node installed in the environment.
  [WARN]  The `GITHUB_TOKEN` has to be set in the environment.
```
 
 just copy the `build-chain-action` command execution (and npm installation command if needed) and paste it in your terminal/console.
</details>

<details>
<summary>
How to retest this PR or trigger a specific build:
</summary>

* <b>a pull request</b> please add comment: <b>Jenkins retest</b> (using <i>this</i> e.g. <b>Jenkins retest this</b> optional but no longer required)
 
* <b>a full downstream build</b> please add comment: <b>Jenkins run fdb</b>
  
* <b>a compile downstream build</b> please  add comment: <b>Jenkins run cdb</b>

* <b>a full production downstream build</b> please add comment: <b>Jenkins execute product fdb</b>

* <b>an upstream build</b> please add comment: <b>Jenkins run upstream</b>
</details>
