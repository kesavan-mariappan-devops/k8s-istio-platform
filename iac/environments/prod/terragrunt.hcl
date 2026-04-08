# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
# https://github.com/kesavan-mariappan-devops/k8s-istio-platform

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/k8s-app"
}

inputs = {
  env               = "prod"
  namespace         = "k8s-istio-platform-prod"
  host              = "k8s-istio-platform.local"
  backend_replicas  = 2
  frontend_replicas = 1
  backend_image     = "k8s-istio-platform-backend:latest"
  frontend_image    = "k8s-istio-platform-frontend:latest"
}
