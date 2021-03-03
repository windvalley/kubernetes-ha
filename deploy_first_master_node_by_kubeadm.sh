#!/usr/bin/env bash
# deploy_first_master_node_by_kubeadm.sh
#


# e.g. 1.20.4
K8S_VERSION=1.20.4
RIP_INTERFACE=eth1
APISERVER_PORT=6443
VIP_DOMAIN=master-vip.sre.im
POD_CIDR=172.16.0.0/16
SERVICE_CIDR=10.96.0.0/12
IMAGE_REPO=registry.aliyuncs.com/google_containers

local_rip=$(ip a show "$RIP_INTERFACE"|
    grep inet|head -1|awk '{print $2}'|awk -F/ '{print $1}')
kubeadm_init="kubeadm init \
    --kubernetes-version v$K8S_VERSION \
    --control-plane-endpoint $VIP_DOMAIN \
    --apiserver-advertise-address $local_rip \
    --apiserver-bind-port $APISERVER_PORT \
    --pod-network-cidr $POD_CIDR \
    --service-cidr $SERVICE_CIDR \
    --image-repository $IMAGE_REPO"


[[ -z "$K8S_VERSION" ]] && {
    echo "please execute 'init_env.sh' first"
    exit 1
}

[[ "$HOME" != "/root" ]] && {
    echo "please execute the script with sudo"
    exit 1
}


workdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
logdir=$workdir/logs
dryrun_logfile=$logdir/kubeadm_init_dry_run.log
init_logfile=$logdir/kubeadm_init.log
action=$1

[[ ! -d "$logdir" ]] && mkdir -p "$logdir"

# You can pull images first in this way
#kubeadm config images pull --image-repository "$IMAGE_REPO"

case $action in
    test)
        $kubeadm_init --dry-run &>"$dryrun_logfile"
        cat "$dryrun_logfile"
        ;;
    deploy)
        $kubeadm_init &>"$init_logfile"
        cat "$init_logfile"
        ;;
    *)
        echo "Usage: $0 <test|deploy>"
        ;;
esac

