provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = "default"
  }
}

# Redis Deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "redis:6.2"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis-service"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

# PostgreSQL Deployment
resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:13"
          env {
            name  = "POSTGRES_DB"
            value = "votingdb"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          port {
            container_port = 5432
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres-storage"
          }
        }
        volume {
          name = "postgres-storage"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# Worker Deployment
resource "kubernetes_deployment" "worker" {
  metadata {
    name      = "worker-app-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "worker"
      }
    }
    template {
      metadata {
        labels = {
          app = "worker"
        }
      }
      spec {
        container {
          name  = "worker"
          image = "govind2439/worker-app:v1"
          env {
            name  = "REDIS_HOST"
            value = "redis-service"
          }
          env {
            name  = "POSTGRES_HOST"
            value = "postgres-service"
          }
          env {
            name  = "POSTGRES_DB"
            value = "votingdb"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Voting Application Deployment
resource "kubernetes_deployment" "vote" {
  metadata {
    name      = "vote-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "vote"
      }
    }
    template {
      metadata {
        labels = {
          app = "vote"
        }
      }
      spec {
        container {
          name  = "vote"
          image = "govind2439/vote-app:v1"
          env {
            name  = "REDIS_HOST"
            value = "redis-service"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vote" {
  metadata {
    name      = "vote-service"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "vote"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Result Application Deployment
resource "kubernetes_deployment" "result" {
  metadata {
    name      = "result-deployment"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "result"
      }
    }
    template {
      metadata {
        labels = {
          app = "result"
        }
      }
      spec {
        container {
          name  = "result"
          image = "govind2439/result-app:v1"
          env {
            name  = "POSTGRES_HOST"
            value = "postgres-service"
          }
          env {
            name  = "POSTGRES_DB"
            value = "votingdb"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "result" {
  metadata {
    name      = "result-service"
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "result"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

