# DevOps Portfolio — k8s-istio-platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/kesavan-mariappan-devops/k8s-istio-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/kesavan-mariappan-devops/k8s-istio-platform/actions/workflows/ci.yml)
[![Build](https://github.com/kesavan-mariappan-devops/k8s-istio-platform/actions/workflows/build.yml/badge.svg)](https://github.com/kesavan-mariappan-devops/k8s-istio-platform/actions/workflows/build.yml)
[![Maintainer](https://img.shields.io/badge/maintainer-kesavan--mariappan-blue)](https://github.com/kesavan-mariappan)

A full-stack microservices application built to demonstrate production-grade DevOps practices: containerisation, Kubernetes orchestration, Istio service mesh, and a CI/CD pipeline with GitHub Actions.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React + Vite, served via Nginx |
| Backend | Node.js + Express (v1 & v2) |
| Containerisation | Docker, Docker Compose |
| Orchestration | Kubernetes (Minikube) |
| Service Mesh | Istio 1.21 |
| CI/CD | GitHub Actions + GHCR |
| IaC | Terraform + Terragrunt |
| Manifest Validation | kubeconform |
| Code Quality | pre-commit hooks |

---

## Architecture

![Architecture Diagram](docs/architecture.png)

### Key Features Demonstrated

- **Canary deployment** — 90/10 traffic split between `mesh-api` v1 and v2 via Istio VirtualService + DestinationRule
- **mTLS** — STRICT PeerAuthentication enforced across `backend` and `frontend` namespaces
- **Authorisation policy** — deny-all default; only the `frontend` namespace can call `mesh-api` on `GET /api*` and `/health*`
- **Resilience** — circuit breaker (outlier detection), retries, and a 3s timeout on the VirtualService
- **Fault injection** — dedicated manifest to simulate 50% latency + 20% HTTP 500s for resilience testing
- **Health probes** — liveness and readiness probes on all deployments
- **Resource limits** — CPU and memory requests/limits on every container
- **CI/CD pipeline** — pre-commit checks → lint → test → build → push to GHCR → validate manifests → deploy dev (auto) → prod (manual approval)
- **Pre-commit hooks** — trailing whitespace, YAML/JSON validation, secret detection, Terraform fmt/validate, Hadolint, Gitleaks, ESLint (backend + frontend)

---

## Project Structure

```
k8s-istio-platform/
├── backend/                  # Express.js API (mesh-api v1 + v2)
│   ├── src/
│   │   ├── index.js          # v1 — app entry point + Express routes
│   │   ├── index.v2.js       # v2 — canary version
│   │   └── index.test.js     # unit tests (node:test)
│   ├── Dockerfile
│   └── Dockerfile.v2
├── frontend/                 # React + Vite SPA (mesh-ui)
│   └── src/App.jsx
├── k8s/
│   ├── namespace.yaml        # backend + frontend namespaces
│   ├── ingress.yaml          # NGINX Ingress for both services
│   ├── backend/              # mesh-api Deployment (v1 & v2), Service
│   ├── frontend/             # mesh-ui Deployment, Service
│   └── istio/
│       ├── gateway.yaml
│       ├── virtualservice-backend.yaml   # canary 90/10 + retries + timeout
│       ├── virtualservice-frontend.yaml
│       ├── destinationrule-backend.yaml  # ROUND_ROBIN + circuit breaker
│       ├── authz-policy.yaml             # deny-all + allow frontend→mesh-api
│       ├── mtls-peer-auth.yaml           # STRICT mTLS both namespaces
│       └── fault-injection.yaml          # resilience testing (revert after use)
├── iac/
│   ├── environments/
│   │   ├── terragrunt.hcl    # root config (provider, state)
│   │   ├── dev/              # namespace: k8s-istio-platform-dev, 1 replica
│   │   └── prod/             # namespace: k8s-istio-platform-prod, 2 replicas
│   └── modules/k8s-app/      # reusable Terraform module
├── docs/
│   └── architecture.png
├── .github/
│   └── workflows/
│       ├── ci.yml            # PR: pre-commit + lint + test + build check
│       ├── build.yml         # push to main: docker build + push GHCR
│       └── deploy.yml        # after build: validate manifests + deploy stages
├── .pre-commit-config.yaml   # pre-commit hook definitions (local + CI)
├── deploy.sh                 # local Minikube deploy script
└── docker-compose.yml        # local development
```

---

## CI/CD Pipeline

```
PR opened → main
  └── ci.yml
        ├── Pre-commit: YAML/JSON lint, secret scan, Terraform fmt, Hadolint, Gitleaks, ESLint
        ├── Backend:    lint + test (node:test)
        └── Frontend:   lint + build check

PR merged → main
  └── build.yml
        └── Docker build + push to GHCR (git SHA + latest tags)
              └── deploy.yml
                    ├── validate-manifests: kubeconform offline schema validation
                    │     (18 resources — k8s + Istio CRDs)
                    ├── deploy-dev:  auto deploy (environment: dev)
                    └── deploy-prod: manual approval gate (environment: prod)
```

### GitHub Environments & Secrets

| Name | Type | Value |
|---|---|---|
| `IMAGE_PREFIX` | Variable | `ghcr.io/kesavan-mariappan-devops` |
| `IMAGE_REGISTRY` | Secret | `ghcr.io` |
| `KUBECONFIG` | Secret | Base64-encoded kubeconfig (set when deploying to a live cluster) |
| `dev` | Environment | No protection rules — auto deploy |
| `prod` | Environment | Required reviewer: manual approval gate |

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | /health | Health check — uptime, env, timestamp, version |
| GET | /api/info | App metadata — name, version, description |
| GET | /api/slow | Slow endpoint (5s) — demonstrates Istio 3s timeout |

---

## Pre-commit Hooks

Install and activate hooks locally:
```bash
pip install pre-commit
pre-commit install
```

Run against all files manually:
```bash
pre-commit run --all-files
```

Hooks run automatically on every `git commit` and on every PR via `ci.yml`.

| Hook | What it checks |
|---|---|
| `check-yaml` | Malformed k8s/Istio YAML |
| `check-json` | Malformed JSON files |
| `detect-private-key` | Accidental private key commits |
| `terraform_fmt/validate` | IaC formatting and validity |
| `terragrunt_fmt` | Terragrunt HCL formatting |
| `check-github-workflows` | Workflow YAML schema |
| `hadolint-docker` | Dockerfile best practices |
| `gitleaks` | Secret scanning |
| `backend-lint` | ESLint on `backend/src/` |
| `frontend-lint` | ESLint on `frontend/src/` |

---

## Run Locally

**Docker Compose (recommended)**
```bash
docker compose up --build
```
Frontend: http://localhost:3000
Backend: http://localhost:5000

**Without Docker**
```bash
cd backend && npm install && npm run dev
cd frontend && npm install && npm run dev
```

---

## Deploy to Minikube

**Prerequisites**
```bash
minikube start
minikube addons enable ingress
istioctl install --set profile=demo -y
kubectl label namespace backend istio-injection=enabled
kubectl label namespace frontend istio-injection=enabled
```

**Deploy**
```bash
./deploy.sh
```

Add to `/etc/hosts`:
```
<minikube-ip>  k8s-istio-platform.backend.local
<minikube-ip>  k8s-istio-platform.frontend.local
```

| URL | Description |
|---|---|
| http://k8s-istio-platform.frontend.local | mesh-ui (Frontend) |
| http://k8s-istio-platform.backend.local/api/info | mesh-api info |
| http://k8s-istio-platform.backend.local/health | Health check |

**Useful commands**
```bash
kubectl get all -n backend
kubectl get all -n frontend
kubectl logs -l app=mesh-api -n backend
istioctl proxy-status
```

---

## IaC — Terraform + Terragrunt

```bash
cd iac/environments/dev
terragrunt apply

cd iac/environments/prod
terragrunt apply
```

To enable CI/CD cluster deploys, set the `KUBECONFIG` secret:
```bash
cat ~/.kube/config | base64 | tr -d '\n'
# paste output into GitHub → Settings → Secrets → Actions → KUBECONFIG
```

---

## Istio — Resilience Testing

Apply fault injection (50% delay + 20% abort):
```bash
kubectl apply -f k8s/istio/fault-injection.yaml
```

Revert to normal canary routing:
```bash
kubectl apply -f k8s/istio/virtualservice-backend.yaml
```
