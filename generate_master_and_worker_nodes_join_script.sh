#!/usr/bin/env bash
# generate_master_and_worker_nodes_join_script.sh
#


RIP_INTERFACE=eth1

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
logdir=$workdir/logs
init_logfile=$logdir/kubeadm_init.log


cat >master_nodes_join.sh <<EOF
#!/usr/bin/env bash
# master_nodes_join.sh
#


local_rip=\$(ip a show "$RIP_INTERFACE"|
    grep inet|head -1|awk '{print \$2}'|awk -F/ '{print \$1}')

sudo $(grep -A3 "kubeadm join" "$init_logfile" | head -3) --apiserver-advertise-address="\$local_rip"

EOF

cat >worker_nodes_join.sh <<EOF
#!/usr/bin/env bash
# worker_nodes_join.sh
#


sudo $(grep -A3 "kubeadm join" "$init_logfile" | tail -2)

EOF

chmod u+x master_nodes_join.sh worker_nodes_join.sh

