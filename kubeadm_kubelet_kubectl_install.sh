#!/usr/bin/env bash
# kubeadm_kubelet_kubectl_install.sh
#


# e.g. 1.20.4
K8S_VERSION=1.20.4
RIP_INTERFACE=eth1


local_rip=$(ip a show "$RIP_INTERFACE"|
    grep inet|head -1|awk '{print $2}'|awk -F/ '{print $1}')


[[ -z "$K8S_VERSION" ]] && {
    echo "please execute 'init_env.sh' first"
    exit 1
}

[[ "$HOME" != "/root" ]] && {
    echo "please execute the script with sudo"
    exit 1
}


# packages.cloud.google.com
tee /etc/yum.repos.d/kubernetes.repo <<<"[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg 
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
"

yum remove -y {kubelet,kubectl,kubeadm}
yum list kubelet kubectl kubeadm --showduplicates|sort -k3nr

yum install -y {kubelet,kubectl,kubeadm}-"$K8S_VERSION"

# systemd service of kubelet
#ls /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

sed -i "/^KUBELET_EXTRA_ARGS=/s/^.*$/KUBELET_EXTRA_ARGS=\"--node-ip=$local_rip\"/" /etc/sysconfig/kubelet

systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet

