# Security Policy

## Maintainer

**Kesavan Mariappan** — [@kesavan-mariappan](https://github.com/kesavan-mariappan)

## Supported Versions

| Version | Supported |
|---|---|
| `main` branch | ✅ |
| Older branches | ❌ |

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities privately via GitHub:
**[Security Advisories](https://github.com/kesavan-mariappan-devops/k8s-istio-platform/security/advisories/new)**

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You will receive a response within **7 days**. If the vulnerability is confirmed, a fix will be prioritised and a security advisory published.

## Scope

This is a portfolio/demonstration project. The following are in scope:

- Kubernetes manifest misconfigurations (RBAC, network policies, privilege escalation)
- Istio security policy bypasses (mTLS, AuthorizationPolicy)
- Secrets or credentials accidentally committed
- Dockerfile security issues (running as root, exposed secrets)
- Dependency vulnerabilities in `backend/` or `frontend/`

## Security Practices in This Project

- STRICT mTLS enforced across all namespaces via `PeerAuthentication`
- Zero-trust `AuthorizationPolicy` — deny-all default, explicit allow rules only
- No secrets committed — `KUBECONFIG` stored as GitHub Actions encrypted secret
- Resource limits on all containers to prevent resource exhaustion
- Non-root container execution via Nginx unprivileged image
