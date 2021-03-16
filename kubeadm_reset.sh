#!/usr/bin/env bash
# kubeadm_reset.sh
#


[[ "$HOME" = "/root" ]] && {
    echo "can not execute with sudo"
    exit 1
}


sudo kubeadm reset

sudo rm -rf /etc/cni/net.d

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -t raw -F

sudo ipvsadm --clear

rm -rf "$HOME"/.kube/
