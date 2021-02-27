#!/usr/bin/env bash
# centos_init.sh
#


[[ "$HOME" != "/root" ]] && {
    echo "please execute the script with sudo"
    exit 1
}

sync_time(){
    local cron_file=/var/spool/cron/vagrant

    yum install -y ntpdate
    timedatectl set-timezone Asia/Shanghai
    /usr/sbin/ntpdate time1.aliyun.com

    if [[ ! -f $cron_file ]] || ! grep -q ntpdate $cron_file; then
        echo '*/5 * * * * sudo /usr/sbin/ntpdate time1.aliyun.com' >>$cron_file
    fi
}

sync_time

yum update -y
yum install -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp \
    net-tools vim telnet

systemctl stop firewalld
systemctl disable firewalld
iptables -F
iptables -X
iptables -F -t nat
iptables -X -t nat
iptables -P FORWARD ACCEPT

systemctl stop dnsmasq
systemctl disable dnsmasq

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
setenforce 0

swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

tee /etc/sysctl.d/kubernetes.conf <<<"net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
"
sysctl -p /etc/sysctl.d/kubernetes.conf

