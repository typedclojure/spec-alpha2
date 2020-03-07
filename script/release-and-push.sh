#!/bin/bash
#
# Cuts a release of spec-alpha2. Requires two arguments:
# - the release version to use
# - the development SNAPSHOT version to use
#
# eg., to cut version 1.0.0 and then move to 1.0.1-SNAPSHOT,
# call this script like so:
#
#   ./script/release-and-push.sh 1.0.0 1.0.1-SNAPSHOT
#
# and then push the resulting commit to the master branch.
# GitHub Actions will automatically deploy a 1.0.0 release and
# update the dev version to 1.0.1-SNAPSHOT.

set -e

DEPLOY_BRANCH="typedclojure"
DEPLOY_REPO="typedclojure/spec-alpha2"
ALLOWED_ACTOR="frenchy64"
USER_EMAIL="abonnairesergeant@gmail.com"
USER_NAME="Ambrose Bonnaire-Sergeant"


if [[ "$GITHUB_ACTIONS" != 'true' ]]; then
  echo "Must release on GitHub Actions only."
  exit 1
fi

if [[ `git symbolic-ref --short HEAD` != "$DEPLOY_BRANCH" ]]; then
  echo "Releases only triggered on the master branch. Doing nothing."
  exit 0
fi

if [[ "$GITHUB_ACTOR" != "$ALLOWED_ACTOR" ]]; then
  echo "Only maintainers may deploy a release. Doing nothing."
  exit 0
fi

if [[ "$GITHUB_REPOSITORY" != "$DEPLOY_REPO" ]]; then
  echo "Releases only allowed from $DEPLOY_REPO. Doing nothing."
  exit 0
fi

git config --local user.email "$USER_EMAIL"
git config --local user.name "$USER_NAME"

RELEASE_VERSION=$1
DEVELOPMENT_VERSION=$2

if [[ -z "$RELEASE_VERSION" ]]; then
  echo "Must specify release version"
  exit 1
fi

if [[ -z "$DEVELOPMENT_VERSION" ]]; then
  echo "Must specify development version"
  exit 1
fi

# there's a chance this can fail and we have a partial
# release to Clojars. We minimize the damage by avoiding
# pushing back to master, but there's a chance the version
# was partially deployed. The correct fix (wrt clojars) is to simply
# deploy a new version (eg., if 1.0.0 fails, try 1.0.1 next).
( set -x;
mvn release:prepare release:perform \
  -DreleaseVersion="$RELEASE_VERSION" \
  -Dtag="$RELEASE_VERSION" \
  -DdevelopmentVersion="$DEVELOPMENT_VERSION"
  )

#( set -x;
#./script/bump-readme-version "$RELEASE_VERSION"
#)

#git add .
#git commit -m "Bump README versions for $RELEASE_VERSION"

# DON'T PRINT HERE
git push "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" "${DEPLOY_BRANCH}" --tags
