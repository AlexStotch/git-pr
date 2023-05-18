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

pr_shortcut_card() {
    local auth_token; auth_token=$(echo -n "${SHORTCUT_TOKEN}")

    local source_branch; source_branch=$(git_current_branch)
    local id; id=$(echo "$source_branch" | grep -E -o "[0-9]+")

    local l_story; l_story=$(curl -X GET \
      -H "Content-Type: application/json" \
      -H "Shortcut-Token: $auth_token" \
      -d '{ "page_size": 1, "query": "id:'"$id"'" }' \
      -L "https://api.app.shortcut.com/api/v3/search/stories" \
        2>/dev/null \
      | jq -c .data[0])

      echo "$l_story"
}

pr_card_url() {
  local auth_token; auth_token=$(echo -n "${GITHUB_TOKEN}")
  local source_branch; source_branch=$(git_current_branch)
  local card_url; card_url=$(pr_shortcut_card | jq -r ".branches[] | select(.name == \"$source_branch\") | .pull_requests[].url as \$url | \$url")

  return "$card_url"
}

pr_shortcut_card_link() {
  local card_url; card_url=$(pr_shortcut_card | jq -r .app_url)

   echo "### [Card]($card_url)"
}

pr_format_description() {
    local source_branch=${1:-$(git_current_branch)}
    local title='# Description'
    local card_url; card_url=$(pr_shortcut_card_link "$source_branch")

    pr_print_description "$title" "$card_url" "$(pr_commit_list "$source_branch")"
}

pr_requested_reviewers_pending() {
  local auth_token; auth_token=$(echo -n "${GITHUB_TOKEN}")
  local source_branch; source_branch=$(git_current_branch)
  local card_url; card_url=$(pr_shortcut_card | jq -r ".branches[] | select(.name == \"$source_branch\") | .pull_requests[].url as \$url | \$url")
  local api_card_url; api_card_url=$(echo "$card_url" | sed 's/github/api.github.com\/repos/g;s/pull/pulls/g' | sed 's/repos\.com/repos/g')

  local requested_reviewers; requested_reviewers=$(curl -s -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $auth_token"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$api_card_url/requested_reviewers")

    if [[ -z $requested_reviewers ]]; then
      echo "No PR created"
      exist 1
    fi

    echo "$requested_reviewers" | jq -r '.users[].login, .teams[].name'
}

pr_requested_reviewers() {
  local auth_token; auth_token=$(echo -n "${GITHUB_TOKEN}")
  local source_branch; source_branch=$(git_current_branch)
  local card_url; card_url=$(pr_shortcut_card | jq -r ".branches[] | select(.name == \"$source_branch\") | .pull_requests[].url as \$url | \$url")
  local api_card_url; api_card_url=$(echo "$card_url" | sed 's/github/api.github.com\/repos/g;s/pull/pulls/g' | sed 's/repos\.com/repos/g')

  local reviews; reviews=$(curl -s -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $auth_token"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$api_card_url/reviews")

    if [[ -z $reviews ]]; then
      echo "No PR created"
      exist 1
    fi

    echo "$reviews"
}

pr_requested_reviewers_commented() {
    local reviews=$1
    echo "$reviews" | jq -r '.[] | select(.state == "COMMENTED") | .user.login' | sort -u
}

pr_requested_reviewers_approved() {
    local reviews=$1
    echo "$reviews" | jq -r '.[] | select(.state == "APPROVED") | .user.login' | sort -u
}

pr_status() {
  local requested_reviewers; requested_reviewers=$(pr_requested_reviewers)
  local requested_reviewers_pending; requested_reviewers_pending=$(pr_requested_reviewers_pending)
  local requested_reviewers_commented; requested_reviewers_commented=$(pr_requested_reviewers_commented "$requested_reviewers")
  local requested_reviewers_approved; requested_reviewers_approved=$(pr_requested_reviewers_approved "$requested_reviewers")

  if [[ -n $requested_reviewers_pending ]]; then
    echo "--------------------------------------------------------------------------------"
    echo -e "Waiting for review 🔄\n"
    for reviewer in $requested_reviewers_pending; do
      echo "$reviewer"
    done
  fi

  if [[ -n $requested_reviewers_commented ]]; then
    echo "--------------------------------------------------------------------------------"
    echo -e "Reviews Commented 🗨\n"
    for reviewer in $requested_reviewers_commented; do
      echo "$reviewer"
    done
  fi

  if [[ -n $requested_reviewers_approved ]]; then
    echo "--------------------------------------------------------------------------------"
    echo -e "Reviews Approved ✅\n"
    for reviewer in $requested_reviewers_approved; do
      echo "$reviewer"
    done
  fi
}

pr_description() {
    local source_branch=${1:-$(git_current_branch)}

    local description;
        description=$(pr_format_description "$source_branch")
        cat <<EOF

--------------------------------------------------------------------------------
$description

EOF
}

pr_open() {
xdg-open "$(pr_card_url)"
}

# Variables
################################################################################
SHORTCUT_TOKEN=${SHORTCUT_TOKEN:-$(git config --get pr.shortcut-token || true)}
GITHUB_TOKEN=${GITHUB_TOKEN:-$(git config --get pr.github-token || true)}
################################################################################
# Run

# Init

git rev-parse > /dev/null 2>&1  || exit_error "$ERR_GIT_REPO" "Not a git repository"

# Run
case $1 in
    -d|description) pr_description "${@:2}";;
    -o|open) pr_open "${@:2}";;
    -s|status) pr_status "${@:2}";;
esac
