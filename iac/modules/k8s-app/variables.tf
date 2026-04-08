# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
# https://github.com/kesavan-mariappan-devops/k8s-istio-platform

variable "env" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "backend_image" {
  description = "mesh-api container image"
  type        = string
  default     = "k8s-istio-platform-backend:latest"
}

variable "frontend_image" {
  description = "mesh-ui container image"
  type        = string
  default     = "k8s-istio-platform-frontend:latest"
}

variable "backend_replicas" {
  description = "Number of mesh-api replicas"
  type        = number
  default     = 1
}

variable "frontend_replicas" {
  description = "Number of mesh-ui replicas"
  type        = number
  default     = 1
}

variable "host" {
  description = "Ingress hostname"
  type        = string
}
