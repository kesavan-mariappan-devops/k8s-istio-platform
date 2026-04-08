# IaC — Terraform + Terragrunt

Manages Kubernetes deployments for `mesh-api` and `mesh-ui` across `dev` and `prod` environments using a reusable Terraform module.

## Structure

```
iac/
├── modules/
│   ├── k8s-app/          # reusable module: namespace, deployments, services, ingress
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vm/               # optional VM provisioning via Libvirt
├── environments/
│   ├── terragrunt.hcl    # root config — kubernetes provider + local state
│   ├── dev/
│   │   └── terragrunt.hcl  # namespace: k8s-istio-platform-dev, 1 replica
│   └── prod/
│       └── terragrunt.hcl  # namespace: k8s-istio-platform-prod, 2 replicas
└── vm/
    └── terragrunt.hcl
```

## Prerequisites

```bash
# Terraform
brew install terraform   # or https://developer.hashicorp.com/terraform/install

# Terragrunt
brew install terragrunt  # or https://terragrunt.gruntwork.io/docs/getting-started/install/

# Minikube must be running with ingress enabled
minikube start
minikube addons enable ingress
```

> Terraform formatting and validation are also enforced via pre-commit hooks (`terraform_fmt`, `terraform_validate`, `terragrunt_fmt`) on every `git commit` and PR.

## Deploy to dev

```bash
cd iac/environments/dev
terragrunt apply
```

Add to `/etc/hosts`:
```
$(minikube ip)  dev.k8s-istio-platform.local
```

Open: http://dev.k8s-istio-platform.local

## Deploy to prod

```bash
cd iac/environments/prod
terragrunt apply
```

Add to `/etc/hosts`:
```
$(minikube ip)  k8s-istio-platform.local
```

Open: http://k8s-istio-platform.local

## Deploy all environments at once

```bash
cd iac/environments
terragrunt run-all apply
```

## Useful commands

```bash
terragrunt plan           # preview changes
terragrunt apply          # apply changes
terragrunt destroy        # tear down
terragrunt run-all plan   # plan all environments
```

## Module inputs

| Variable | Description | dev default | prod default |
|---|---|---|---|
| `env` | Environment name | `dev` | `prod` |
| `namespace` | Kubernetes namespace | `k8s-istio-platform-dev` | `k8s-istio-platform-prod` |
| `host` | Ingress hostname | `dev.k8s-istio-platform.local` | `k8s-istio-platform.local` |
| `backend_image` | mesh-api image | `k8s-istio-platform-backend:latest` | `k8s-istio-platform-backend:latest` |
| `frontend_image` | mesh-ui image | `k8s-istio-platform-frontend:latest` | `k8s-istio-platform-frontend:latest` |
| `backend_replicas` | mesh-api replica count | `1` | `2` |
| `frontend_replicas` | mesh-ui replica count | `1` | `1` |
