#!/bin/bash

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the rebooting script."
echo "This script will update your system and then reboot."
echo "Parameters:"
echo " 1. Optional delay until reboot procedure is started, by default '60s', but you can specify any other time that 'sleep' accepts."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): This script is in directory '$scriptDir', where we also will look for other scripts."

delay="${1:-}"
sudo "$scriptDir/__shutDownOrReboot.sh" "$scriptDir" "reboot" "$delay"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Reboot is initiated. See you soon."
