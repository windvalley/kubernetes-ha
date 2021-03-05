#!/usr/bin/env bash
# calico_cni_install.sh
#
# This script Install Calico with Kubernetes API datastore, 50 nodes or less, 
# if you have more than 50 nodes in k8s, please refer to this document:
# https://docs.projectcalico.org/archive/v3.18/getting-started/kubernetes/self-managed-onprem/onpremises


CALICO_VERSION=3.18

workdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
addons_dir=$workdir/addons


[[ "$HOME" = "/root" ]] && {
    echo "can not execute with sudo"
    exit 1
}

[[ -z "$CALICO_VERSION" ]] && {
    echo "please execute 'init_env.sh' first"
    exit 1
}

[[ ! -d "$addons_dir" ]] && mkdir -p "$addons_dir"


( 
    cd "$addons_dir" || exit 1
    curl https://docs.projectcalico.org/archive/v"$CALICO_VERSION"/manifests/calico.yaml -O
)

kubectl apply -f "$addons_dir"/calico.yaml

# shellcheck disable=SC2034
# It will output as follows:
output="
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
daemonset.apps/calico-node created
serviceaccount/calico-node created
deployment.apps/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
poddisruptionbudget.policy/calico-kube-controllers created
"

# After several minitues, execute this command
#kubectl get pods -n kube-system

# shellcheck disable=SC2034
# And you will see all pods are ready:
output="
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-6949477b58-x7l6f   1/1     Running   0          12m
calico-node-vrg4p                          1/1     Running   0          12m
coredns-7f89b7bc75-frj2b                   1/1     Running   0          63m
coredns-7f89b7bc75-g659f                   1/1     Running   0          63m
etcd-node1.sre.im                          1/1     Running   0          63m
kube-apiserver-node1.sre.im                1/1     Running   1          63m
kube-controller-manager-node1.sre.im       1/1     Running   0          63m
kube-proxy-vk5g9                           1/1     Running   0          63m
kube-scheduler-node1.sre.im                1/1     Running   0          63m
"

