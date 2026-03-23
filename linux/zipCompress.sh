#!/bin/bash

# Compress files and folders to .zip archives, using the strongest
# available zip compression.
# This compression is generally worse than tar.xz compression.
# Later, you can decompress the generated archive with the command
# "unzip archive.zip".
#
# The script can be called in two ways:
#
# 1. With a single parameter 'X', which can be either a file or directory.
#    Then, an archive with name 'X.zip' is created and the contents of 'X'
#    are packaged into it.
#
# 2. With multiple parameters 'Y', 'A', 'B', 'C', and so on.
#    Then, an archive with name 'Y.zip' is created and the contents of 'A',
#    'B', and 'C', and so on are packaged into it.
#    'Y' is treated solely as archive name, not as source.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

dest="${1%/}"
dest="$(basename "$dest").zip"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination archive name is '$dest'."

if [ $# \> 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Beginning to compress sources '${@:2}' to destination '$dest'"
    nice -n 19 zip -9 -r "$dest" "${@:2}"
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Beginning to compress sources '$1' to destination '$dest'"
    nice -n 19 zip -9 -r "$dest" "$1"
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done compressing to destination '$dest'."
