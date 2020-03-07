#! /bin/bash
# Deploys either a snapshot or release in GitHub Actions.
# If the commit message is of the form:
#   [typedclojure-release] <release-version> <new-dev-version>

set -e

if [[ "$GITHUB_ACTIONS" != 'true' ]]; then
  echo "Only call this script in GitHub Actions"
  exit 1
fi 

if [[ "$GITHUB_REPOSITORY" != 'frenchy64/spec-alpha2' ]]; then
  echo "This script only deploys in frenchy64/spec-alpha2, not $GITHUB_REPOSITORY. Doing nothing."
  exit 0
fi

COMMIT_MSG=$(git log --format=%B -n 1 "${GITHUB_SHA}")
echo $COMMIT_MSG
if [[ "$COMMIT_MSG" =~ ^\[prep-release\] ]]; then
  #https://stackoverflow.com/a/9294015
  COMMIT_MSG_ARRAY=($COMMIT_MSG)
  ./script/release-and-push.sh "${COMMIT_MSG_ARRAY[1]}" "${COMMIT_MSG_ARRAY[2]}"
else
  echo "Not deploying snapshot releases"
  #./script/deploy-snapshot.sh
fi
