#!/bin/bash

# This script attempts all sorts of update approaches.
# The goal is to update all packages, including apt-get as well as snaps.

# Fail on error.
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): The update script has started."

cd /tmp/  # Just to be on the save side.

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Clearing caches and locks by force."
sudo rm -rf "/var/lib/apt/lists/lock" || true
sudo rm -rf "/var/cache/apt/archives/lock" || true
sudo rm -rf "/var/lib/dpkg/lock" || true

# updating the system
for i in {1..4}; do
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now doing apt-get updates in run ${i}."
  echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Cleaning caches (1)."
	sudo apt-get -y clean
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Cleaning caches (2)."
	sudo apt-get -y autoclean
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Automatically remove packages that were installed to satisfy dependencies but are no longer needed (and deleting their configuration)."
	sudo apt-get -y autoremove --purge
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Deleting configurations no longer needed."
	sudo apt-get -y purge
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Getting current list of available packages."
	sudo apt-get -y update
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Getting current list of available packages, ignoring broken or missing packages."
	sudo apt-get -y update --fix-missing
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Resume and complete the configuration of packages that were unpacked but not fully configured, if any."
	sudo dpkg --configure -a
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Try to install missing dependencies or broken packages (1)."
	sudo apt-get -y --fix-missing install
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Try to install missing dependencies or broken packages (2)."
	sudo apt-get -y -f install
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Updating installed packages, installing new packages if needed."
	sudo apt-get -y --with-new-pkgs upgrade
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Verify that there are no broken dependencies."
	sudo apt-get -y check
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Try to install missing broken dependencies."
	sudo apt -y --fix-broken install
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished doing apt-get updates in run ${i}, now doing snap updates."
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Refreshing snaps (1)."
	sudo snap refresh
	sleep 1
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Terminating any snap store process that may prevent us from refreshing."
	sudo killall snap-store || true
	sleep 5
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Refreshing snaps (2)."
	sudo snap refresh
	echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Finished doing run ${i}."
	sleep 10
done

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Done updating."
