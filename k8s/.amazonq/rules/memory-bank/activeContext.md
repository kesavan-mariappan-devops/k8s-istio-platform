# Active Context

## Current Focus
Working within the Istio configuration layer — specifically `virtualservice-backend.yaml` (canary routing with retries/timeout).

## Recent Activity
- Memory Bank initialized from full project scan

## Active File
`k8s/istio/virtualservice-backend.yaml` — backend VirtualService defining:
- Hosts: `k8s-istio-platform.backend.local` + `backend.backend.svc.cluster.local`
- Gateways: `istio-system/k8s-istio-platform-gateway` + `mesh`
- Routes: `/api` and `/health` prefixes → 90% v1 / 10% v2
- Timeout: 3s, Retries: 3 attempts / 1s perTry / on 5xx,gateway-error,reset

## Known Constraints
- `imagePullPolicy: Never` — images must exist locally on the cluster node before applying
- Fault injection is a temporary override of `backend-vs`; always revert with `virtualservice-backend.yaml`
- AuthorizationPolicy only allows GET on `/api*` and `/health*` — POST/PUT/DELETE from frontend will be denied

## Next Likely Tasks
- Adjusting canary weights (e.g. promoting v2 to 50/50 or 100%)
- Adding header-based routing for targeted v2 testing
- Extending AuthorizationPolicy for additional HTTP methods
- Adding TLS termination to the Istio Gateway
