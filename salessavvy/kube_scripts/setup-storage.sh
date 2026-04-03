#!/bin/bash
# setup-storage.sh
# Creates a hostPath PersistentVolume for MySQL data on a kubeadm single-node cluster

echo "Creating host directory for MySQL data..."
sudo mkdir -p /mnt/data/mysql
sudo chmod 777 /mnt/data/mysql

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data/mysql
EOF

echo "✅ PersistentVolume 'mysql-pv' created."
