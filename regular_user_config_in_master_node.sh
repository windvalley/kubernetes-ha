#!/usr/bin/env bash
# regular_user_config_in_master_node.sh
#


[[ "$HOME" = "/root" ]] && {
    echo "can not execute with sudo"
    exit 1
}

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u):$(id -g)" "$HOME"/.kube/config

