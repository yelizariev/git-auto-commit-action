#!/bin/sh

set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  ACTOR=${INPUT_GITHUB_LOGIN:-$GITHUB_ACTOR}
  echo "ACTOR: $ACTOR"
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $ACTOR
        password $INPUT_GITHUB_TOKEN

        machine api.github.com
        login $ACTOR
        password $INPUT_GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "$INPUT_COMMIT_AUTHOR_EMAIL"
    git config --global user.name "$INPUT_COMMIT_AUTHOR_NAME"
}

echo "INPUT_REPOSITORY value: $INPUT_REPOSITORY";

cd $INPUT_REPOSITORY

# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if [[ -n "$(git status -s)" ]]
then
    git_setup

    echo "INPUT_BRANCH value: $INPUT_BRANCH";

    # Switch to branch from current Workflow run
    git checkout $INPUT_BRANCH

    echo "INPUT_FILE_PATTERN: ${INPUT_FILE_PATTERN}"

    git add "${INPUT_FILE_PATTERN}"

    echo "INPUT_COMMIT_AUTHOR_EMAIL: $INPUT_COMMIT_AUTHOR_EMAIL"
    echo "INPUT_COMMIT_AUTHOR_NAME: $INPUT_COMMIT_AUTHOR_NAME"
    echo "INPUT_COMMIT_OPTIONS: ${INPUT_COMMIT_OPTIONS}"

    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>" ${INPUT_COMMIT_OPTIONS:+"$INPUT_COMMIT_OPTIONS"}

    git push --set-upstream origin "HEAD:$INPUT_BRANCH"
else
    echo "Working tree clean. Nothing to commit."
fi
