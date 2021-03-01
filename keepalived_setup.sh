#!/usr/bin/env bash
# keepalived_setup.sh
#
# master node1: ./keepalived_setup.sh master
# master node2: ./keepalived_setup.sh backup
#


RIP_INTERFACE=eth1
VIP=192.168.33.100

basedir=/etc/keepalived
monitor_script=$basedir/check-apiserver.sh
role=$1
# shellcheck disable=2021,2155
state_role=$(echo "$role"|tr "[a-z]" "[A-Z]")

if [[ $role == "master" ]]; then
    priority=100
elif [[ $role == "backup" ]]; then
    priority=99
else
    echo "Usage: $0 <master|backup>"
    exit 1
fi

yum install -y keepalived

mkdir -p $basedir
tee $basedir/keepalived.conf <<<"! Configuration File for keepalived
global_defs {
    router_id keepalive-$role
}

vrrp_script check_apiserver {
    script \"$monitor_script\"
    interval 3
    weight -2
}

vrrp_instance VI-kube-master {
    state $state_role
    interface $RIP_INTERFACE
    virtual_router_id 68
    priority $priority
    dont_track_primary
    advert_int 3
    virtual_ipaddress {
        $VIP
   }
   track_script {
       check_apiserver
   }
}
"

tee $basedir/check-apiserver.sh <<<"#!/bin/bash
netstat -nltp | grep -qw 6443 || exit 1
"

chmod +x $basedir/check-apiserver.sh

systemctl enable keepalived
systemctl start keepalived
systemctl status keepalived
#journalctl -f -u keepalived

sleep 3
ip a | grep "$RIP_INTERFACE"

