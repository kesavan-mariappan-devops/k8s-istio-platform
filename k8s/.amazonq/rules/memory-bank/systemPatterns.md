# System Patterns

## Architecture Overview
```
[Client]
   |
   ├── NGINX Ingress (k8s-istio-platform.backend.local, k8s-istio-platform.frontend.local)
   └── Istio Gateway (istio-system/k8s-istio-platform-gateway)
          |
          ├── frontend VirtualService → frontend pod (namespace: frontend)
          │       frontend pod ──mesh──► backend VirtualService
          └── backend VirtualService → backend v1 (90%) / v2 (10%) (namespace: backend)
```

## Namespaces
| Namespace | Contents |
|-----------|----------|
| `frontend` | frontend Deployment (1 replica), Service (NodePort 30080), PeerAuthentication |
| `backend` | backend v1 Deployment (2 replicas), backend v2 Deployment (1 replica), Service, PeerAuthentication, AuthorizationPolicy |
| `istio-system` | Istio Gateway |

## Key Design Patterns

### Canary Deployment
- DestinationRule defines subsets `v1` (label `version: v1`) and `v2` (label `version: v2`)
- VirtualService splits weight 90/10 between subsets
- Both subsets share the same Service (`backend`) on port 5000

### Traffic Management
- Timeout: 3s on backend routes
- Retries: 3 attempts, 1s perTryTimeout, on `5xx,gateway-error,reset`
- Load balancer: ROUND_ROBIN across backend replicas
- Connection pool: http1MaxPendingRequests=10, http2MaxRequests=100
- Circuit breaker: eject after 3 consecutive 5xx, 30s base ejection, max 50% ejected

### Security (Zero-Trust)
- STRICT mTLS via PeerAuthentication in both namespaces
- Default-deny AuthorizationPolicy (`backend-deny-all`) with empty spec
- Explicit allow: `backend-allow-frontend` — source namespaces `[frontend, istio-system]`, GET only, paths `/api*` and `/health*`

### Dual Ingress
- NGINX Ingress: direct K8s path-based routing (no mesh awareness)
- Istio Gateway + VirtualService: mesh-aware routing with full traffic policies

### Fault Injection (Learning Exercise)
- `fault-injection.yaml` overrides `backend-vs` with 50% delay (3s) + 20% abort (HTTP 500)
- Revert by re-applying `virtualservice-backend.yaml`

## File Map
```
k8s/
├── namespace.yaml                        # frontend + backend namespaces
├── ingress.yaml                          # NGINX Ingress for both services
├── backend/
│   ├── deployment.yaml                   # backend v1, 2 replicas
│   ├── deployment-v2.yaml                # backend v2, 1 replica
│   └── service.yaml                      # ClusterIP :5000
├── frontend/
│   ├── deployment.yaml                   # frontend, 1 replica
│   └── service.yaml                      # NodePort 30080
└── istio/
    ├── gateway.yaml                      # Istio Gateway in istio-system
    ├── virtualservice-backend.yaml       # canary routing + retries/timeout
    ├── virtualservice-frontend.yaml      # simple passthrough to frontend
    ├── destinationrule-backend.yaml      # subsets, LB, circuit breaker
    ├── authz-policy.yaml                 # deny-all + allow frontend→backend
    ├── mtls-peer-auth.yaml               # STRICT mTLS both namespaces
    └── fault-injection.yaml              # resilience test (temporary)
```
