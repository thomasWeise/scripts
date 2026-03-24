#!/bin/bash

# This script executes a command while limiting its number of CPU cores and memory consumption.
#
# Parameters:
# 1. The maximum number of CPU cores to use.
# 2. The maximum amount of memory to use, units are B for bytes,
#    K for kilobytes, M for megabytes, G for gigabytes, T for terabytes
#    and so on.
# After these two parameters, the command and all of its arguments follow.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# \< 3 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Need at least three arguments. Quitting."
    exit 1
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the program execution script for command '${@:3}'."
cpus="$1"
if [ "$cpus" -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Cannot use '$cpus' CPU cores. Quitting."
    exit 1
fi
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will permit the use of at most '$cpus' CPU cores."

memory="$2"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will permit the use of at most this '$memory' of memory."

set +o errexit
nice -n 19 taskset -c "$cpus" systemd-run --scope -p MemoryMax="$memory" --user "${@:3}"
retcode="$?"
set -o errexit

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The program has ended with exit code '$retcode'."
exit "$retcode"
