#!/bin/bash

# Try a command forever.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the forever-trying script."

command="$1"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The command is '$command'."

logBase="${2:-}"
if [ -n "$logBase" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The log base is '$logBase'."
    cycle=1
    log="$logBase${cycle}.txt"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle and log file '$log'."
    while ! $command 1>"$log" 2>&1 ; do
        cycle=$((cycle+1))
        log="$logBase${cycle}.txt"
        sleep 20s
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle and log file '$log'."
    done
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Logging to stdout."
    cycle=1
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle."
    while ! $command 2>&1 ; do
        cycle=$((cycle+1))
        sleep 20s
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle."
    done
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We have finished the process."
