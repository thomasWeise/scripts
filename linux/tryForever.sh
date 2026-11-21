#!/bin/bash

# Try a command until it succeeds, loop forever if necessary.
# This script expects two parameters:
#
# 1. the command to execute
#
# 2. optionally, a path to use as blueprint for per-execution log files
#    If this log base is not provided, the output goes directly to the
#    console.
#    If this log base is, e.g., "/tmp/log", then log files of the form
#    "/tmp/logXXX.txt" will be generated, where XXX is replaced with the
#    index of the attempt.


# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

if [ $# -lt 1 ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Execute a command until it succeeds."
    echo "Parameters:"
    echo " 1. the command to execute"
    echo " 2. OPTIONAL: a pattern for log files to create (index + .txt will be appended)"
    echo " 3. OPTIONAL: a delay between attempts; default 20s"
    exit 1
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the forever-trying script."

command="$1"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The command is '$command'."

delay="${3:-}"
if [ -n "$delay" ]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will use the specified delay of '$delay'."
else
  delay=20s
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We will use the default delay of '$delay'."
fi

logBase="${2:-}"
if [ -n "$logBase" ]; then
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The log base is '$logBase'."
    cycle=1
    log="$logBase${cycle}.txt"
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle and log file '$log'."
    while ! $command 1>"$log" 2>&1 ; do
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Attempt $cycle failed."
        cycle=$((cycle+1))
        log="$logBase${cycle}.txt"
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now sleeping for ${delay}, then doing attempt $cycle and log file '$log'."
        sleep "$delay"
    done
else
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Logging to stdout."
    cycle=1
    echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing attempt $cycle."
    while ! $command 2>&1 ; do
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Attempt $cycle failed."
        cycle=$((cycle+1))
        echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now sleeping for ${delay}, then doing attempt $cycle."
        sleep "$delay"
    done
fi

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We have finished the process successfully."
