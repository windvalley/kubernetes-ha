#!/usr/bin/env bash
# docker_install.sh
#


DOCKER_VERSION=


[[ -z "$DOCKER_VERSION" ]] && {
    echo "please execute 'init_env.sh' first"
    exit 1
}

[[ "$HOME" != "/root" ]] && {
    echo "please execute the script with sudo"
    exit 1
}


yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    container-selinux \
    docker-ce docker-ce-cli containerd.io

groupdel docker

# choose a stable version
#yum list docker-ce --showduplicates | sort -r

yum-config-manager --add-repo \
    https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo

sed -i 's/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g' \
    /etc/yum.repos.d/docker-ce.repo

yum makecache fast
yum install -y docker-ce-"$DOCKER_VERSION" docker-ce-cli-"$DOCKER_VERSION" containerd.io

systemctl enable docker
systemctl start docker

# default: /var/lib/docker
mkdir -p /docker-data
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",

  "registry-mirrors": ["https://hub-mirror.c.163.com"],
  "graph": "/docker-data",
}
EOF

systemctl restart docker
usermod -aG docker "$SUDO_USER"

