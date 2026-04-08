# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
# https://github.com/kesavan-mariappan-devops/k8s-istio-platform

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}

output "ingress_host" {
  value = var.host
}

output "frontend_node_port" {
  value = kubernetes_service.mesh_ui.spec[0].port[0].node_port
}
