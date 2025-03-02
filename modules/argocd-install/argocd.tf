resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.id
}

resource "random_password" "client_secret" {
  length  = 20
  special = false
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  timeout      = 1200
  force_update = true
  namespace    = kubernetes_namespace.argocd.id
  values = [<<EOF
server:
  replicas: 1
  metrics:
    enabled: true

controller:
  replicas: 1
  metrics:
    enabled: true

repoServer:
  replicas: 1
  metrics:
    enabled: true

configs:
  params:
    "server.insecure": true
EOF
  ]
}
