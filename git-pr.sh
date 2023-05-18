#!/usr/bin/env bash

################################################################################
# Git functions

git_current_branch() {
    # `git branch --show-current` is available starting from Git 2.22
    # fallback to `git rev-parse --abbrev-ref HEAD` if first command fails
    (git branch --show-current 2>/dev/null) ||
        git rev-parse --abbrev-ref HEAD
}

git_base_branch() {
  local base_branch; base_branch=$(git show-branch |
   grep '*' |
   grep -v "$(git rev-parse --abbrev-ref HEAD)" |
   head -n1 |
   sed 's/.*\[\(.*\)\].*/\1/' |
   sed 's/[\^~].*//')

  echo "$base_branch"
}

git_commits() {
    local source_branch=${1:-$(git_current_branch)}
    local target_branch; target_branch=$(git_base_branch)

    git log --oneline --reverse --no-decorate "${target_branch}..${source_branch}"
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
    local card_url=$2
    if [[ -n $3 ]]; then
        local commit_list=$3
        cat <<EOF
${title}

${card_url}

## Commits

${commit_list}

EOF
    else
        cat <<EOF
$(markdown_title "$title")

EOF
    fi
}

pr_shortcut_card_link() {
  local auth_token; auth_token=$(echo -n "${SHORTCUT_TOKEN}")

  local id; id=$(echo chore/sc-77765-flaky-php-test-chatpopularcoursesquerytest | grep -E -o "[0-9]+")

  local l_story; l_story=$(curl -X GET \
    -H "Content-Type: application/json" \
    -H "Shortcut-Token: $auth_token" \
    -d '{ "page_size": 1, "query": "id:'"$id"'" }' \
    -L "https://api.app.shortcut.com/api/v3/search/stories" \
      2>/dev/null \
    | jq -c .data[0] | jq -r .app_url)

   echo "### [Card]($l_story)"
}


pr_description() {
    local source_branch=${1:-$(git_current_branch)}
    local title='# Description'
    local card_url; card_url=$(pr_shortcut_card_link "$source_branch")

    pr_print_description "$title" "$card_url" "$(pr_commit_list "$source_branch")"
}

pr_open() {
    local source_branch=${1:-$(git_current_branch)}

    local description;
        description=$(pr_description "$source_branch")
        cat <<EOF

--------------------------------------------------------------------------------
$description

EOF

#https://app.shortcut.com/studocu/story/47141/showing-organic-posts-in-single-question-page
# https://github.com/StuDocu/studocu/tree/feature/sc-76978-create-chatmessageattachable-table
# branch= test/tt
#google-chrome "https://github.com/StuDocu/studocu/compare/master...test/tt"
#google-chrome "https://github.com/StuDocu/studocu/compare/master...$source_branch"
}

# Variables
################################################################################
SHORTCUT_TOKEN=${SHORTCUT_TOKEN:-$(git config --get pr.shortcut-token || true)}

################################################################################
# Run

# Init

git rev-parse > /dev/null 2>&1  || exit_error "$ERR_GIT_REPO" "Not a git repository"

# Run
case $1 in
    -d|description) pr_open "${@:2}";;
esac
