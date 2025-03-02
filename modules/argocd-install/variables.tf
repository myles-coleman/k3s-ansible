variable "chart_version" {
  description = "The version of the ArgoCD Helm Chart to install"
  type        = string
  default     = "6.10.2"
}

variable "kubernetes_context" {
  description = "The Kubernetes context to use from the kubeconfig file"
  type        = string
  default     = "default"
}