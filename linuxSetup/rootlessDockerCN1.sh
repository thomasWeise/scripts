#!/bin/bash -

# Install rootless docker using domestic Chinese mirrors and registries, step 1.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the Rootless Docker Installation in China Script, Step 1."

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): First we update the list of packages from the package repository."
sudo apt-get -y update --fix-missing

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We install the needed packages 'ca-certificates', 'curl', 'gnupg', and 'lsb-release', if they have not yet been installed."
sudo apt-get install --fix-missing -y ca-certificates curl gnupg lsb-release

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we enable the domestic Chinese package repository from aliyun."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we install the docker binaries step 1."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Docker is now installed in version:"
docker --version

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We prepare some domestic registry mirrors in '/etc/docker'."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.m.daocloud.io",
    "https://huecker.io"
  ]
}
EOF

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We re-load and restart docker."
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): We install some requirements for running rootless docker."
sudo apt-get install --fix-missing -y uidmap
sudo apt-get install --fix-missing -y slirp4netns

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now we need to stop and deactivate the root-full docker service."
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd

sudo systemctl disable docker
sudo systemctl disable docker.socket
sudo systemctl disable containerd

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Please reboot now and continue with second installation script 'rootlessDockerCN2.sh'."
