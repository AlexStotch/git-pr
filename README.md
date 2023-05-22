# git-pr

Prepares a merge request description, with a link to Shortcut card and current branch commits list.

**Table of contents** 
1. [Commands](#commands)
   - [Description](#description)  
   - [Status](#status)  
   - [Open](#open)  	
3. [Installation](#installation)


## Commands

```
git mr -d|description
git mr -s|status
git mr -o|open
```
### Description
`git mr -d|description`

Get a PR description that you can copy/past and complete when you create the PR.
![image](https://github.com/AlexStotch/git-pr/assets/32511699/52885ff3-d241-4c14-a8a2-b3a43eca70ad)
![image](https://github.com/AlexStotch/git-pr/assets/32511699/7ab4a546-dddf-461a-bde4-406df31a75c5)

### Status
`git mr -s|status`

Get you PR status: PR's link, reviwers review status.
![image](https://github.com/AlexStotch/git-pr/assets/32511699/d8fa4722-9b5f-41e1-befe-4d70607acf22)

### Open 
`git mr -o|open`

Open your GitHub PR in your browser

## Installation
### Command installation
Dependencies
`bash`, `git` and usual command-line utilities: `grep`, `sed`, `curl`, `head`, `tail`, `tr`.
https://stedolan.github.io/jq/ is required and needs to be in PATH.

### git-pr
Add the git-pr directory to your PATH
in one of your shell startup scripts:
```
PATH="${PATH}:/path/to/git-pr"
```
OR

Define it as a Git alias:
run:
```
git config --global alias.pr '!bash /path/to/git-mr/git-pr'
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
