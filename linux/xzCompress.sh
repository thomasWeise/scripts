#!/bin/bash

# Compress files and folders to .tar.xz archives, using the strongest
# available compression.
# Later, you can decompress the generated archive with the command
# "tar -xf archive.tar.xz".
#
# The script can be called in two ways:
#
# 1. With a single parameter 'X', which can be either a file or directory.
#    Then, an archive with name 'X.tar.xz' is created and the contents of 'X'
#    are packaged into it.
#
# 2. With multiple parameters 'Y', 'A', 'B', 'C', and so on.
#    Then, an archive with name 'Y.tar.xz' is created and the contents of 'A',
#    'B', and 'C', and so on are packaged into it.
#    'Y' is treated solely as archive name, not as source.
#
# This script may take a lot of memory and time.
# If you have N logical CPU cores, this script attempts to use
# max{1, ((N-1)/2)-1} threads and launches the compressor with niceness of 19.
# Therefore, the system should still be usable during compression.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Compress files or folders to tar.xz."
    echo "Parameters --- EITHER ----"
    echo " 1. file or folder to compress, will create 'name + .tar.xz' archive"
    echo "Parameters --- OR ----"
    echo " 1. base name for archive; '.tar.xz' will be appended"
    echo " 2., 3., ... paths to files or folders to compress"
    exit 1
fi

dest="${1%/}"
dest="$(basename "$dest").tar.xz"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Destination archive name is '$dest'."

if command -v nproc &> /dev/null; then
    nthreads="$(nproc --all)"
    nthreads="$((nthreads - 1))"
    nthreads="$((nthreads / 2))"
    nthreads="$((nthreads - 1))"
    if [ $nthreads -le 1 ]; then
        nthreads=1
    fi
else
    nthreads=1
fi
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Using $nthreads threads."

if [ $# \> 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Beginning to compress sources '${@:2}' to destination '$dest'"
    nice -n 19 tar -c "${@:2}" | xz --threads=$nthreads -v -9e -c > "$dest"
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Beginning to compress sources '$1' to destination '$dest'"
    nice -n 19 tar -c "$1" | xz --threads=$nthreads -v -9e -c > "$dest"
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done compressing to destination '$dest'."
