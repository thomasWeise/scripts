#!/bin/bash -

# This script downloads a GitHub repository, squashes all commits into the current state, and re-uploads it.
# This basically removes the entire history of the project.
# It assumes that the project can be accessed via SS.
# Parameters:
#   1. the user name for the GitHub repository
#   2. the name of the repository

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Truncate the history of a GitHub repository."
    echo "Parameters:"
    echo " 1. the user name to the GitHub repository"
    echo " 2. the name of the repository"
    exit 1
fi

user="$1"
repo="$2"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Truncating repository '$repo' of user '$user'."

tempDir="$(mktemp -d)"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The temporary directory is '$tempDir'."
cd "$tempDir"

repoStr="ssh://git@github.com/$user/$repo"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): First we clone the repository url '$repoStr'."
echo "Command: 'git clone $repoStr'"
git clone "$repoStr"
cd "$repo"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Successfully cloned the repository '$repoStr', now we create a new branch."
echo "Command: 'git checkout --orphan newBranch'"
git checkout --orphan newBranch
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We created the new branch, now we add all the files."
echo "Command: 'git add -A'"
git add -A  # Add all files and commit them
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We added all the files, now we create a commit. You may need to enter a commit title/message."
echo "Command: 'git commit'"
git commit
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We created the commit, now we delete the main branch."
echo "Command: 'git branch -D main'"
git branch -D main  # Deletes the main branch
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We deleted the main branch, now we rename the current branch to main."
echo "Command: 'git branch -m main'"
git branch -m main  # Rename the current branch to main
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we force-pushe the (new) main branch to GitHub."
echo "Command 'git push -f origin main'"
git push -f origin main  # Force push main branch to github
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we prune the repository."
echo "Command: 'git gc --aggressive --prune=all'"
git gc --aggressive --prune=all     # remove the old files
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): All done."
