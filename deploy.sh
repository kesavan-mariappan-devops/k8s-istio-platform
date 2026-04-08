# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
# https://github.com/kesavan-mariappan-devops/k8s-istio-platform

#!/bin/bash
set -e

echo "==> Pointing Docker to minikube's daemon..."
eval $(minikube docker-env)

echo "==> Building backend image..."
docker build -t k8s-istio-platform-backend:latest ./backend

echo "==> Building frontend image..."
docker build -t k8s-istio-platform-frontend:latest ./frontend

echo "==> Applying Kubernetes manifests..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/ingress.yaml

echo "==> Waiting for pods to be ready..."
kubectl rollout status deployment/mesh-api -n backend
kubectl rollout status deployment/mesh-ui -n frontend

MINIKUBE_IP=$(minikube ip)

echo ""
echo "==> Deployment complete!"
echo "    Add to /etc/hosts:"
echo "      $MINIKUBE_IP  k8s-istio-platform.backend.local"
echo "      $MINIKUBE_IP  k8s-istio-platform.frontend.local"
echo ""
echo "    Backend:  http://k8s-istio-platform.backend.local/api"
echo "    Health:   http://k8s-istio-platform.backend.local/health"
echo "    Frontend: http://k8s-istio-platform.frontend.local"
