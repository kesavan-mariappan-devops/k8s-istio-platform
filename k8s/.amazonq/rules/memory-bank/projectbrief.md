# Project Brief

## Project Name
k8s-istio-platform

## Purpose
A Kubernetes-based sample application demonstrating Istio service mesh capabilities including traffic management, security policies, and resilience testing.

## Core Requirements
- Deploy a frontend and backend application across separate Kubernetes namespaces
- Use Istio for traffic routing, canary deployments, mTLS, and authorization
- Expose services via Istio Gateway and NGINX Ingress
- Support canary traffic splitting between backend v1 (90%) and v2 (10%)
- Enforce zero-trust security: deny-all by default, allow only frontend → backend traffic

## Scope
- Kubernetes manifests only (no application source code in this workspace)
- Infrastructure-as-code for local/dev cluster (imagePullPolicy: Never implies local images)
