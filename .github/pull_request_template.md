**Thank you for submitting this pull request**

**JIRA**: _(please edit the JIRA link if it exists)_ 

[link](https://www.example.com)

**referenced Pull Requests**: _(please edit the URLs of referenced pullrequests if they exist)_

* paste the link(s) from GitHub here
* link 2
* link 3 etc.

You can check Kiegroup organization repositories CI status from [Chain Status webpage](https://kiegroup.github.io/droolsjbpm-build-bootstrap/)

<details>
<summary>
How to replicate CI configuration locally?
</summary>

Build Chain tool does "simple" maven build(s), the builds are just Maven commands, but because the repositories relates and depends on each other and any change in API or class method could affect several of those repositories there is a need to use [build-chain tool](https://github.com/kiegroup/github-action-build-chain) to handle cross repository builds and be sure that we always use latest version of the code for each repository.
 
[build-chain tool](https://github.com/kiegroup/github-action-build-chain) is a build tool which can be used locally on command line or in Github Actions workflow(s), in case you need to change multiple repositories and send multiple dependent pull requests related with a change you can easily reproduce the same build by executing it on Github hosted environment or locally in your development environment. See [local execution](https://github.com/kiegroup/github-action-build-chain#local-execution) details to get more information about it. 

A general local execution could be the following one, where the tool clones all dependent projects starting from the `-sp` one and it locally applies the pull request (if it exists) in order to reproduce a complete build scenario for the provided *Pull Request*.

> **Note:** the tool considers multiple *Pull Requests* related to each other if their branches (generally in the forked repositories) have the same name.

``` shell
$ build-chain-action -df 'https://raw.githubusercontent.com/${GROUP:kiegroup}/droolsjbpm-build-bootstrap/${BRANCH:main}/.ci/pull-request-config.yaml' build pr -url <pull-request-url> -sp kiegroup/kie-wb-distributions [--skipExecution]
```

> Consider changing `kiegroup/kie-wb-distributions` with the correct starting project.


</details>

<details>
<summary>
How to retest this PR or trigger a specific build:
</summary>

* <b>a pull request</b> please add comment: <b>Jenkins retest</b> (using <i>this</i> e.g. <b>Jenkins retest this</b> optional but no longer required)
 
* for a <b>full downstream build</b> 
  * for <b>jenkins</b> job: please add comment: <b>Jenkins run fdb</b>
  * for <b>github actions</b> job: add the label `run_fdb`
    
* <b>a compile downstream build</b> please  add comment: <b>Jenkins run cdb</b>

* <b>a full production downstream build</b> please add comment: <b>Jenkins execute product fdb</b>

* <b>an upstream build</b> please add comment: <b>Jenkins run upstream</b>

* <b>for windows-specific os job</b> add the label `windows_check`
</details>
