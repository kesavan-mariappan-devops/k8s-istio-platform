# Product Context

## Why This Project Exists
A learning/reference project for Istio service mesh patterns on Kubernetes. It demonstrates real-world traffic management, security hardening, and resilience testing in a minimal two-service setup.

## Problems It Solves
- Shows how to do canary releases without changing application code (Istio weight-based routing)
- Demonstrates zero-trust networking with mTLS + AuthorizationPolicy
- Provides a safe fault-injection exercise to test resilience (fault-injection.yaml)
- Illustrates dual ingress: NGINX Ingress for raw K8s access + Istio Gateway for mesh-aware routing

## How It Should Work
1. User hits `k8s-istio-platform.frontend.local` → Istio Gateway → frontend VirtualService → frontend pod
2. Frontend calls backend internally via `backend.backend.svc.cluster.local`
3. Istio routes 90% of backend traffic to v1, 10% to v2 (canary)
4. mTLS is enforced STRICT in both namespaces; only frontend/istio-system may call backend GET /api* or /health*
5. Retries (3 attempts, 1s perTry) and a 3s timeout protect backend calls
6. Circuit breaker ejects pods after 3 consecutive 5xx errors

## Key User Flows
- Normal traffic: frontend → backend v1 (90%) / v2 (10%)
- Resilience test: apply fault-injection.yaml (50% delay, 20% abort), then revert with virtualservice-backend.yaml
