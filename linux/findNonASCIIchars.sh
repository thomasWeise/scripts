#!/bin/bash

# This script searches for characters that are non in the normal ASCII range in a document.
# As argument, it expects the path to the file to check.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Find non-ASCII characters in a file."
    echo "Parameters:"
    echo " 1. path to file"
    exit 1
fi

srcDocument="$(realpath "$1")"

if [ -f "$srcDocument" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now searching for non-ASCII characters in document '$srcDocument'."
  if (grep --color='auto' -P -n '[^\x00-\x7F]' "$srcDocument"); then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Found some non-ASCII characters in document '$srcDocument'."
  else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): No non-ASCII characters found in document '$srcDocument'."
  fi
else
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): '$srcDocument' is not a file."
  exit 1
fi
