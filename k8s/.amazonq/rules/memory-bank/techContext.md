# Tech Context

## Technologies Used
| Technology | Role |
|------------|------|
| Kubernetes | Container orchestration |
| Istio (networking.istio.io/v1beta1, security.istio.io/v1beta1) | Service mesh — traffic management, mTLS, authz |
| NGINX Ingress Controller | Raw K8s ingress (non-mesh path) |
| Docker (local images) | Container runtime; `imagePullPolicy: Never` means images are pre-loaded locally |

## Container Images
| Image | Tag | Namespace |
|-------|-----|-----------|
| `k8s-istio-platform-backend` | `v1` | backend |
| `k8s-istio-platform-backend` | `v2` | backend |
| `k8s-istio-platform-frontend` | `latest` | frontend |

## Ports
| Service | Port | Type |
|---------|------|------|
| backend | 5000 | ClusterIP |
| frontend | 80 (container), 30080 (NodePort) | NodePort |
| Istio Gateway | 80 HTTP | LoadBalancer (istio-ingressgateway) |

## Hostnames
| Hostname | Resolves To |
|----------|-------------|
| `k8s-istio-platform.backend.local` | Istio Gateway / NGINX Ingress → backend |
| `k8s-istio-platform.frontend.local` | Istio Gateway / NGINX Ingress → frontend |
| `backend.backend.svc.cluster.local` | Internal mesh traffic to backend |
| `frontend.frontend.svc.cluster.local` | Internal mesh traffic to frontend |

## Resource Limits
| Workload | CPU Request | CPU Limit | Memory Request | Memory Limit |
|----------|-------------|-----------|----------------|--------------|
| backend v1/v2 | 100m | 250m | 128Mi | 256Mi |
| frontend | 50m | 100m | 64Mi | 128Mi |

## Health Checks
Both backend and frontend use HTTP liveness and readiness probes:
- backend: `GET /health :5000`, liveness delay 10s/15s, readiness delay 5s/10s
- frontend: `GET / :80`, same timing pattern

## Istio API Versions
- `networking.istio.io/v1beta1` — Gateway, VirtualService, DestinationRule
- `security.istio.io/v1beta1` — PeerAuthentication, AuthorizationPolicy
