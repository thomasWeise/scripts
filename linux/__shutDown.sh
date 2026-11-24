#!/bin/bash

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

scriptDir="$1"
delay="${2:-}"
if [[ -n "$delay" ]]; then
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): A delay of '$delay' was specified."
else
  delay="60s"
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The default delay of '$delay' will be used."
fi
sleep "${delay}"
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished waiting for '$delay', now shutting down."

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now updating the system via update script '$scriptDir/update.sh'."
set +o errexit
"$scriptDir/update.sh"
retVal=$?
set -o errexit
echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Update script has returned (return value $retVal)."

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now sleeping for 60s, just in case."
sleep 60s

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now shutting down."
sudo systemctl poweroff -i
