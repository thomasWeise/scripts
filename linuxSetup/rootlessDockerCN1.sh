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

### reboot

sudo apt install -y docker-ce-rootless-extras

sudo sh -eux <<EOF
# Load nf_tables module
modprobe nf_tables
EOF


which dockerd-rootless-setuptool.sh


dockerd-rootless-setuptool.sh install



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
systemctl --user restart docker




sudo loginctl enable-linger "$USER"

echo "export DOCKER_HOST=unix:///run/user/1000/docker.sock" >> ~/.bashrc

restart






常见问题排查

    ‌权限问题‌：Rootless Docker 不需要 sudo 来运行容器，但安装 Docker Engine 本身需要 sudo。确保你在执行安装步骤时有 sudo 权限。
    ‌用户组‌：虽然 Rootless 模式不依赖 docker 用户组，但如果你后续想以普通用户身份管理标准 Docker 服务，可以将当前用户加入 docker 组：

    bash
    sudo usermod -aG docker $USER
    newgrp docker

    ‌内核要求‌：确保你的 Ubuntu 内核版本支持 User Namespaces（大多数现代 Ubuntu 版本默认支持）。如果遇到 sysctl 相关错误，可能需要启用 user_namespace：

    bash
    sysctl user.max_user_namespaces=28633


sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.1panel.live/", "https://docker.1ms.run"]
}
EOF
#sudo systemctl daemon-reload
systemctl restart docker



curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce-rootless-extras


which dockerd-rootless-setuptool.sh

dockerd-rootless-setuptool.sh install



mkdir -p ~/.config/docker
tee ~/.config/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.1panel.live",
    "https://docker.1ms.run",
    "https://docker.m.daocloud.io"
  ],
  "storage-driver": "fuse-overlayfs"
}
EOF


systemctl --user enable docker.service
systemctl --user start docker.service
# Allow lingering to keep the service running even when you log out
sudo loginctl enable-linger $USER
