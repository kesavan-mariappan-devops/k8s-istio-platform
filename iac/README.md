# IaC — Terraform + Terragrunt

Manages the full local infrastructure:
- VM provisioning via Libvirt
- Kubernetes deployments on minikube (dev + prod namespaces)

## Structure
```
iac/
├── modules/
│   ├── vm/           # Libvirt VM provisioning
│   └── k8s-app/      # Reusable k8s module (deployment, service, ingress)
├── environments/
│   ├── terragrunt.hcl  # root config (provider, state)
│   ├── dev/            # namespace: sample-app-dev, 1 replica
│   └── prod/           # namespace: sample-app-prod, 2 replicas
└── vm/               # VM provisioning config
```

## Prerequisites
```bash
# Install terraform
brew install terraform   # or https://developer.hashicorp.com/terraform/install

# Install terragrunt
brew install terragrunt  # or https://terragrunt.gruntwork.io/docs/getting-started/install/

# minikube must be running
minikube start
minikube addons enable ingress
```

## Deploy VM (optional)
```bash
cd vm
terragrunt apply
```

## Deploy to dev
```bash
cd environments/dev
terragrunt apply
```

Add to `/etc/hosts`:
```
$(minikube ip)  dev.sample-app.local
```
Open: http://dev.sample-app.local

## Deploy to prod
```bash
cd environments/prod
terragrunt apply
```

Add to `/etc/hosts`:
```
$(minikube ip)  sample-app.local
```
Open: http://sample-app.local

## Deploy all environments at once
```bash
cd environments
terragrunt run-all apply
```

## Useful commands
```bash
terragrunt plan          # preview changes
terragrunt apply         # apply changes
terragrunt destroy       # tear down
terragrunt run-all plan  # plan all envs
```
