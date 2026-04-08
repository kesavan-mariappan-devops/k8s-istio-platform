# Progress

## What Works
- [x] Namespace definitions (frontend, backend)
- [x] Backend v1 Deployment (2 replicas) + Service
- [x] Backend v2 Deployment (1 replica) for canary
- [x] Frontend Deployment (1 replica) + NodePort Service
- [x] NGINX Ingress for both services
- [x] Istio Gateway (`k8s-istio-platform-gateway` in istio-system)
- [x] Backend VirtualService — canary 90/10, retries, timeout
- [x] Frontend VirtualService — simple passthrough
- [x] DestinationRule — subsets v1/v2, ROUND_ROBIN LB, circuit breaker
- [x] mTLS STRICT PeerAuthentication in both namespaces
- [x] AuthorizationPolicy — deny-all + allow frontend/istio-system GET /api* /health*
- [x] Fault injection manifest (learning exercise)

## What's Left / Not Yet Done
- [ ] TLS/HTTPS on Istio Gateway (currently HTTP only)
- [ ] HorizontalPodAutoscaler for backend or frontend
- [ ] NetworkPolicy (Kubernetes-native, separate from Istio authz)
- [ ] Namespace-level resource quotas / LimitRanges
- [ ] CI/CD pipeline or apply ordering script
- [ ] Monitoring/observability manifests (ServiceMonitor, Grafana dashboards)

## Known Issues / Decisions
- Dual ingress (NGINX + Istio) exists for flexibility but can cause confusion; Istio path is the primary mesh-aware route
- `backend-deny-all` uses empty spec `{}` which is the correct Istio pattern for default-deny
- fault-injection.yaml shares the same VirtualService name (`backend-vs`) — applying it replaces the canary VS entirely
