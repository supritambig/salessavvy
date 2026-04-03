#!/bin/bash
# ============================================================
# k8s-deploy.sh
# Deploy SalesSavvy (Spring Boot + React) to Kubernetes
# ============================================================

echo "============================================================"
echo "   Deploying SalesSavvy to Kubernetes (kubeadm)"
echo "============================================================"

echo ""
echo "[1/4] Setting up PersistentVolume for MySQL..."
bash kube_scripts/setup-storage.sh

echo ""
echo "[2/4] Deploying MySQL StatefulSet and Service..."
kubectl apply -f kube_scripts/db-statefulset-svc.yml

echo ""
echo "      Waiting for MySQL to be ready (up to 2 min)..."
kubectl rollout status statefulset/mysql --timeout=120s

echo ""
echo "[3/4] Deploying SalesSavvy app..."
kubectl apply -f kube_scripts/app-deploy-svc.yml

echo ""
echo "[4/4] Waiting for app deployment to be ready..."
kubectl rollout status deployment/salessavvy --timeout=180s

echo ""
echo "============================================================"
echo "✅  Deployment Complete!"
echo ""
echo "  App URL : http://<NodeIP>:30090"
echo "  Customer: Register at /register, login at /"
echo "  Admin   : Go to /admin, login with your ADMIN-role account"
echo "============================================================"
echo ""
kubectl get pods -o wide
echo ""
kubectl get svc
