#!/bin/bash -

# Install rootless docker using domestic Chinese mirrors and registries, step 2.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Welcome to the Rootless Docker Installation in China Script, Step 2."

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Making sure that we have the basic scripts available."
sudo apt install -y docker-ce-rootless-extras

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Ensuring that the 'nf_tables' kernel module is loaded."
sudo sh -eux <<EOF
# Load nf_tables module
modprobe nf_tables
EOF

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Now installing the rootless docker daemon."
dockerd-rootless-setuptool.sh install

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Providing the rootless daemon with the Chinese registry mirrors."
mkdir -p ~/.config/docker
tee ~/.config/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.1panel.live",
    "https://docker.m.daocloud.io",
    "https://hub.rat.dev"
  ],
  "no-new-privileges": false
}
EOF

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Enabling/Starting/Restarting the rootless docker daemon for good measures."
systemctl --user enable docker.service
systemctl --user start docker.service
systemctl --user restart docker

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Making sure that the rootless docker daemon always runs for the current user."
sudo loginctl enable-linger "$USER"

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): Ensuring that 'DOCKER_HOST' environment is always set at login."
echo "export DOCKER_HOST=unix:///run/user/1000/docker.sock" >> ~/.bashrc

echo "$(date +'%0Y-%0m-%0d %0R:%0S'): All done. You can now restart the computer. Docker should now be available as user process and it should use the Chinese domestic package registry mirrors."
