# git-pr

Prepares a merge request description, with a link to Shortcut card and current branch commits list.

[//]: # (![git pr description1]&#40;doc/git-pr.gif&#41;)

**Table of contents** 
1. [Commands](#commands)
   - [Description](#description)  
   - [Status](#status)  
   - [Open](#open)
   - [Create](#create)  	
3. [Installation](#installation)


## Commands

```
git mr -c|create
git mr -d|description
git mr -s|status
git mr -o|open
```

### Create 
`git mr -c|create`

Open a PR for you and add a [Description](#description) to you PR automaticly 

### Description
`git mr -d|description`

Get a PR description that you can copy/past and complete when you create the PR.
![git pr description1](doc/description1.png)
![git pr description2](doc/description2.png)

### Status
`git mr -s|status`

Get you PR status: PR's link, reviwers review status.
![git pr status](doc/status.png)
### Open 
`git mr -o|open`

Open your GitHub PR in your browser

## Installation
### Command installation
Dependencies
`bash`, `git` and usual command-line utilities: `grep`, `sed`, `curl`, `head`, `tail`, `tr`.
https://stedolan.github.io/jq/ is required and needs to be in PATH.
https://cli.github.com/ is required  

### git-pr
Define it as a Git alias:
run:
```
git config --global alias.pr '!bash /path/to/git-mr/git-pr.sh'
```
or edit your ~/.gitconfig directly:
```
[alias]
	pr = "!bash /path/to/git-pr/git-pr.sh"
```

### Shorcut configuration 
To get a Shortcut API Token: https://developer.shortcut.com/api/rest/v3#Authentication
Set this token in your git config:
```
git config --global pr.shortcut-token "abcdefghijklmnopqrstuvwx"
```

### Github configuration 
To get a Github API Token: https://github.com/settings/tokens
Set this token in your git config:
```
git config --global pr.github-token "abcdefghijklmnopqrstuvwx"
```
