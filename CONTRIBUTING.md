# Contributing

Thank you for your interest in contributing to k8s-istio-platform.

## Maintainer

**Kesavan Mariappan** — [@kesavan-mariappan](https://github.com/kesavan-mariappan)
Organisation: [kesavan-mariappan-devops](https://github.com/kesavan-mariappan-devops)

## Branching Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, production-ready code |
| `feature/*` | New features or improvements |
| `fix/*` | Bug fixes |
| `docs/*` | Documentation only changes |

## Workflow

1. Fork the repository
2. Create a branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes — keep commits focused and atomic
4. Ensure CI passes locally before pushing:
   ```bash
   # Backend
   cd backend && npm run lint && npm test

   # Frontend
   cd frontend && npm run lint && npm run build

   # Manifest validation
   kubeconform -kubernetes-version 1.29.0 -ignore-missing-schemas -summary k8s/
   ```
5. Push and open a Pull Request against `main`
6. Fill in the PR template — all checklist items must be addressed

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short description>

Types: feat | fix | docs | chore | refactor | test | ci
```

Examples:
```
feat: add header-based routing for v2 canary testing
fix: resolve mTLS handshake failure on frontend namespace
docs: update deploy instructions for Minikube 1.32
```

## Code Style

- **Backend** — ESLint with `eslint:recommended`, ESM modules
- **Frontend** — ESLint with `eslint-plugin-react-hooks`
- **Kubernetes** — 2-space YAML indentation, resource limits on all containers
- **Terraform** — `terraform fmt` before committing

## Pull Request Requirements

- CI must pass (lint + test + build + manifest validation)
- PR description must explain what changed and why
- Breaking changes must be noted in `CHANGELOG.md` under `[Unreleased]`

## Reporting Issues

Use the GitHub issue templates:
- **Bug report** — for unexpected behaviour
- **Feature request** — for new functionality
