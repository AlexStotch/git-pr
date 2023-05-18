# git-pr

## Commands

```
git mr -d|description  
```

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
