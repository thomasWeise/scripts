#!/bin/bash

# Turn on strict error handling, so that the script fails as soon as something goes wrong.
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Deleting all empty files in current directory recursively."
find . -type f -empty -delete

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Deleting all empty directories in current directory recursively."
find . -type d -empty -delete

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished cleaning up empty files and directories."
