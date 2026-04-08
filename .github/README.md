# GitHub Actions — CI/CD Pipeline

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | Pull Request → main | Lint + test backend; lint + build frontend |
| `build.yml` | Push → main | Build & push Docker images to GHCR (tagged with git SHA + `latest`) |
| `deploy.yml` | After build succeeds | Terragrunt apply → dev (auto), then prod (manual approval) |

## Pipeline Flow

```
PR opened
  └── ci.yml → lint + test + build check

PR merged to main
  └── build.yml → docker build + push to GHCR
        └── deploy.yml
              ├── Terragrunt apply → dev   (automatic)
              └── Terragrunt apply → prod  (requires manual approval)
```

## Required Secrets

| Secret | Description |
|---|---|
| `KUBECONFIG` | Base64-encoded kubeconfig: `cat ~/.kube/config \| base64` |

`GITHUB_TOKEN` is provided automatically by GitHub — no setup needed.

## GitHub Environments

Create two environments in **GitHub → Settings → Environments**:

- `dev` — no protection rules (auto deploy)
- `prod` — add **Required reviewers** to enforce a manual approval gate before production

## Container Images

Images are published to GitHub Container Registry (GHCR):
```
ghcr.io/<your-username>/k8s-istio-platform-backend:<git-sha>
ghcr.io/<your-username>/k8s-istio-platform-backend:latest
ghcr.io/<your-username>/k8s-istio-platform-frontend:<git-sha>
ghcr.io/<your-username>/k8s-istio-platform-frontend:latest
```
