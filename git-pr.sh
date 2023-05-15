#!/usr/bin/env bash

################################################################################
# Git functions

git_current_branch() {
    # `git branch --show-current` is available starting from Git 2.22
    # fallback to `git rev-parse --abbrev-ref HEAD` if first command fails
    (git branch --show-current 2>/dev/null) ||
        git rev-parse --abbrev-ref HEAD
}

git_commits() {
    local source_branch=${1:-$(git_current_branch)}

    git log --oneline --reverse --no-decorate "${source_branch}"
}

markdown_list() {
    local content=$1

    local prefix="* ${MD_BOLD}"
    local suffix="${MD_BOLD}${MD_BR}"

    echo "${prefix}${content//$'\n'/${suffix}$'\n'${prefix}}${suffix}"
}

pr_commit_list() {
    local source_branch=${1:-$(git_current_branch)}

   markdown_list "$(git_commits "$source_branch")"
}

pr_print_description() {
    local title=$1
    if [[ -n $2 ]]; then
        local commit_list=$2
        cat <<EOF
${title}


## Commits

${commit_list}

EOF
    else
        cat <<EOF
$(markdown_title "$title")

EOF
    fi
}

pr_description() {
    local source_branch=${1:-$(git_current_branch)}
    local title='# Description'

    pr_print_description "$title" "$(pr_commit_list "$source_branch")"
}

pr_open() {
    local source_branch=${1:-$(git_current_branch)}

    local description;
        description=$(pr_description "$source_branch")
        cat <<EOF

--------------------------------------------------------------------------------
$description

EOF
}

################################################################################
# Run

# Init

git rev-parse > /dev/null 2>&1    || exit_error "$ERR_GIT_REPO" "Not a git repository"

# Run
case $1 in

#    d|desc) echo "${@:2}";;
    d|desc) pr_open "${@:2}";;
    o|op|open)   mr_open   "${@:2}" ;;

esac
