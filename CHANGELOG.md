# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [1.2.0] — 2025-07-14 — Pre-commit & Pipeline Quality Gates

### Added
- `.pre-commit-config.yaml` — pre-commit hook config covering:
  - `trailing-whitespace`, `end-of-file-fixer`, `check-merge-conflict` — general hygiene
  - `check-yaml` (unsafe mode) — validates all k8s/Istio YAML before commit
  - `check-json` — validates JSON files
  - `detect-private-key` — blocks accidental private key commits
  - `terraform_fmt`, `terraform_validate`, `terragrunt_fmt` — IaC formatting and validation
  - `check-github-workflows` — GitHub Actions workflow schema validation
  - `hadolint-docker` — Dockerfile best practice linting
  - `gitleaks` — secret scanning
  - `backend-lint` (local) — ESLint on `backend/src/`
  - `frontend-lint` (local) — ESLint on `frontend/src/`
- `ci.yml` — `pre-commit` job added to enforce all hooks on every PR to `main`
  - Installs Terraform, Terragrunt, Hadolint, and Node.js deps before running hooks
  - Uses `pre-commit/action@v3.0.1` to run the shared `.pre-commit-config.yaml`

---

## [1.1.0] — 2025-07-14 — Istio Canary Setup

### Added
- `iac/` folder with Terraform + Terragrunt modules for `dev` and `prod` environments
- `iac/modules/k8s-app/` — reusable Terraform module for namespace, deployments, services, and ingress
- `iac/environments/dev/` and `iac/environments/prod/` — environment-specific Terragrunt configs
- `backend/src/index.test.js` — unit tests for `/health` and `/api/info` using Node.js built-in `node:test`
- `backend/.eslintrc.json` — ESLint config with `eslint:recommended` + ESM `sourceType: module`
- `docs/architecture.png` — high-resolution system architecture diagram (6400×4320 px, 300 DPI)
- GitHub repository variable `IMAGE_PREFIX = ghcr.io/kesavan-mariappan-devops`
- GitHub repository secrets `KUBECONFIG` and `IMAGE_REGISTRY`
- GitHub environments `dev` (auto deploy) and `prod` (manual approval — reviewer: `kesavan-mariappan`)
- `CHANGELOG.md` — this file

### Changed
- `deploy.yml` — replaced broken `terragrunt apply` steps with `kubeconform` offline manifest validation
- `deploy.yml` — added `validate-manifests` job that validates all 18 k8s + Istio resources without a cluster
- `deploy.yml` — `deploy-dev` and `deploy-prod` stages emit image tags as `::notice::` for local deploy reference
- `frontend/src/App.jsx` — moved `fetchHealth` inside `useEffect` to fix `react-hooks/set-state-in-effect` lint error; added cancellation flag for safe async cleanup
- `backend/src/index.js` — refactored to export `createServer()` for testability; added ESM `import/export`
- `backend/package.json` — added `"type": "module"` for ESM; fixed test script from glob to explicit path
- All markdown files updated to reflect current project state, app names, and pipeline

### Fixed
- `deploy.yml` — `working-directory: ../iac/environments/dev` → `iac/environments/dev` (runner has no `../iac`)
- `deploy.yml` — removed hardcoded `config_context = "minikube"` from Terragrunt provider config
- `deploy.yml` — replaced `kubectl apply --dry-run=client` (requires live cluster) with `kubeconform` (fully offline)
- `backend` lint — added missing `.eslintrc.json` config file
- `frontend` lint — `react-hooks/set-state-in-effect` error resolved by defining async function inside `useEffect`
- `backend` test — `node --test src/**/*.test.js` glob not expanded on runner; changed to explicit path

---

## [1.0.0] — 2026-04-08 — Initial Release

### Added
- `backend/` — Node.js + Express API (`mesh-api`) with `/health`, `/api/info`, `/api/slow` endpoints
- `backend/Dockerfile` and `Dockerfile.v2` — multi-version container builds
- `frontend/` — React + Vite SPA (`mesh-ui`) polling backend health and displaying app info
- `frontend/Dockerfile` — Nginx-served production container
- `docker-compose.yml` — local development with health-check dependency
- `k8s/namespace.yaml` — `backend` and `frontend` namespaces
- `k8s/backend/deployment.yaml` — `mesh-api` v1, 2 replicas, liveness + readiness probes, resource limits
- `k8s/backend/deployment-v2.yaml` — `mesh-api` v2, 1 replica (canary)
- `k8s/backend/service.yaml` — ClusterIP service on port 5000
- `k8s/frontend/deployment.yaml` — `mesh-ui`, 1 replica
- `k8s/frontend/service.yaml` — NodePort service on port 30080
- `k8s/ingress.yaml` — NGINX Ingress for `mesh-api` and `mesh-ui`
- `k8s/istio/gateway.yaml` — Istio Gateway in `istio-system`
- `k8s/istio/virtualservice-backend.yaml` — canary 90/10 split, 3s timeout, 3 retries on 5xx
- `k8s/istio/virtualservice-frontend.yaml` — passthrough to `mesh-ui`
- `k8s/istio/destinationrule-backend.yaml` — ROUND_ROBIN, circuit breaker (outlier detection)
- `k8s/istio/authz-policy.yaml` — deny-all default + allow `frontend` → `mesh-api` GET `/api*` `/health*`
- `k8s/istio/mtls-peer-auth.yaml` — STRICT mTLS on both namespaces
- `k8s/istio/fault-injection.yaml` — 50% delay (3s) + 20% abort (HTTP 500) for resilience testing
- `.github/workflows/ci.yml` — PR: backend lint + test, frontend lint + build
- `.github/workflows/build.yml` — push to main: Docker build + push to GHCR (git SHA + `latest`)
- `.github/workflows/deploy.yml` — after build: manifest validation + deploy stages
- `deploy.sh` — local Minikube deploy script
- `.gitignore` — Node.js, Python, Terraform, Kubernetes, IDE, OS artefacts

