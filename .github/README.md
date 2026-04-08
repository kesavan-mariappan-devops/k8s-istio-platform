# GitHub Actions — CI/CD Pipeline

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | Pull Request → main | Pre-commit checks + lint + test backend; lint + build frontend |
| `build.yml` | Push → main | Build & push Docker images to GHCR (git SHA + `latest` tags) |
| `deploy.yml` | After build succeeds | Validate k8s manifests with kubeconform → deploy dev (auto) → prod (manual approval) |

## Pipeline Flow

```
PR opened → main
  └── ci.yml
        ├── Pre-commit: YAML/JSON lint, secret scan, Terraform fmt, Hadolint, Gitleaks, ESLint
        ├── Backend:  lint (eslint) + test (node:test)
        └── Frontend: lint (eslint) + build check (vite)

PR merged → main
  └── build.yml → docker build + push to GHCR
        └── deploy.yml
              ├── validate-manifests
              │     kubeconform offline schema validation
              │     18 resources (k8s + Istio CRDs) — no cluster needed
              ├── deploy-dev   (environment: dev — automatic)
              └── deploy-prod  (environment: prod — manual approval required)
```

## Pre-commit Hooks

The `ci.yml` `pre-commit` job enforces the same hooks as local development on every PR.

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

See [`.pre-commit-config.yaml`](../.pre-commit-config.yaml) for full hook definitions.

## GitHub Environments

| Environment | Protection | Purpose |
|---|---|---|
| `dev` | None — auto deploy | Staging / integration |
| `prod` | Required reviewer: `kesavan-mariappan` | Production gate |

## Repository Variables & Secrets

| Name | Type | Description |
|---|---|---|
| `IMAGE_PREFIX` | Variable | `ghcr.io/kesavan-mariappan-devops` |
| `IMAGE_REGISTRY` | Secret | `ghcr.io` |
| `KUBECONFIG` | Secret | Base64-encoded kubeconfig — set to enable live cluster deploys |

To generate `KUBECONFIG`:
```bash
cat ~/.kube/config | base64 | tr -d '\n'
```
Paste into **GitHub → Settings → Secrets → Actions → KUBECONFIG**.

`GITHUB_TOKEN` is provided automatically — no setup needed.

## Container Images

Images are published to GitHub Container Registry (GHCR):
```
ghcr.io/kesavan-mariappan-devops/k8s-istio-platform-backend:<git-sha>
ghcr.io/kesavan-mariappan-devops/k8s-istio-platform-backend:latest
ghcr.io/kesavan-mariappan-devops/k8s-istio-platform-frontend:<git-sha>
ghcr.io/kesavan-mariappan-devops/k8s-istio-platform-frontend:latest
```

## Manifest Validation

`deploy.yml` uses [kubeconform](https://github.com/yannh/kubeconform) to validate all k8s and Istio manifests offline:

```bash
kubeconform \
  -kubernetes-version 1.29.0 \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  -ignore-missing-schemas \
  -summary \
  k8s/
```
