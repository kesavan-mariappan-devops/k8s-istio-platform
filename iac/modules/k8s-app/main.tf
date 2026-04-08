# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Kesavan Mariappan (kesavan-mariappan-devops)
# https://github.com/kesavan-mariappan-devops/k8s-istio-platform

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      env = var.env
    }
  }
}

# ── mesh-api (backend) ────────────────────────────────────────────────────────

resource "kubernetes_deployment" "mesh_api" {
  metadata {
    name      = "mesh-api"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = { app = "mesh-api", env = var.env }
  }
  spec {
    replicas = var.backend_replicas
    selector {
      match_labels = { app = "mesh-api" }
    }
    template {
      metadata {
        labels = { app = "mesh-api", env = var.env }
      }
      spec {
        container {
          name              = "mesh-api"
          image             = var.backend_image
          image_pull_policy = "IfNotPresent"

          port { container_port = 5000 }

          env {
            name  = "NODE_ENV"
            value = var.env
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mesh_api" {
  metadata {
    name      = "mesh-api"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "mesh-api" }
    port {
      port        = 5000
      target_port = 5000
    }
  }
}

# ── mesh-ui (frontend) ────────────────────────────────────────────────────────

resource "kubernetes_deployment" "mesh_ui" {
  metadata {
    name      = "mesh-ui"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = { app = "mesh-ui", env = var.env }
  }
  spec {
    replicas = var.frontend_replicas
    selector {
      match_labels = { app = "mesh-ui" }
    }
    template {
      metadata {
        labels = { app = "mesh-ui", env = var.env }
      }
      spec {
        container {
          name              = "mesh-ui"
          image             = var.frontend_image
          image_pull_policy = "IfNotPresent"

          port { container_port = 80 }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mesh_ui" {
  metadata {
    name      = "mesh-ui"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    type     = "NodePort"
    selector = { app = "mesh-ui" }
    port {
      port        = 80
      target_port = 80
      node_port   = var.env == "prod" ? 30080 : 30081
    }
  }
}

# ── Ingress ───────────────────────────────────────────────────────────────────

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = "k8s-istio-platform-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.host
      http {
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.mesh_api.metadata[0].name
              port { number = 5000 }
            }
          }
        }
        path {
          path      = "/health"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.mesh_api.metadata[0].name
              port { number = 5000 }
            }
          }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.mesh_ui.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
