#!/usr/bin/env bash
# dashboard_deploy.sh
#



dashboard_version=2.0.0
admin_user_name=admin-user


curl https://raw.githubusercontent.com/kubernetes/dashboard/v$dashboard_version/aio/deploy/recommended.yaml \
    -o addons/dashboard-recommended.yaml


# Have not enough permissions
#dashboard_secret=$(get secret -n kubernetes-dashboard|grep kubernetes-dashboard-token|awk '{print $1}')
#kubectl -n kubernetes-dashboard describe secret "$dashboard_secret" | grep token: | awk '{print $2}'

cat >addons/dashboard-adminuser.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $admin_user_name
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $admin_user_name
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $admin_user_name
  namespace: kubernetes-dashboard
EOF

admin_user_secret=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

kubectl -n kubernetes-dashboard describe secret "$admin_user_secret" | grep token: | awk '{print $2}'

