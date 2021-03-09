#!/usr/bin/env bash
# certs_for_other_master_nodes.sh
#


MASTER_NODE1_HOSTNAME=node1.sre.im

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
certs_dir=$workdir/certs
other_master_node_hostname=$1

[[ -z "$other_master_node_hostname" ]] && {
    echo "Usage: $0 other_master_node_hostname"
    exit 1
}

[[ ! -d $certs_dir ]] && mkdir -p "$certs_dir/pki/etcd"


scp -r root@"$MASTER_NODE1_HOSTNAME":/etc/kubernetes/pki "$certs_dir/"

rm -f "$certs_dir"/pki/{apiserver*,front-proxy-client*,etcd/healthcheck*,etcd/server*,etcd/peer*}

scp -r "$certs_dir/pki" root@"$other_master_node_hostname":/etc/kubernetes/

