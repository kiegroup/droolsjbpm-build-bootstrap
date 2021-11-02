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

Build Chain tool does "simple" maven build(s), the builds are just Maven commands, but because the repositories relates and depends on each other and any change in API or class method could affect several of those repositories there is a need to use [build-chain tool](https://github.com/kiegroup/github-action-build-chain) to handle cross repository builds and be sure that we always use latest version of the code for each repository.
 
[build-chain tool](https://github.com/kiegroup/github-action-build-chain) is not only a github-action tool but a CLI one, so in case you posted multiple pull requests related with this change you can easily reproduce the same build by executing it locally. See [local execution](https://github.com/kiegroup/github-action-build-chain#local-execution) details to get more information about it.
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
