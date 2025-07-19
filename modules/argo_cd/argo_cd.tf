# Deploy Argo CD using a Helm chart
resource "helm_release" "argo_cd" {
  name       = var.name                      # Helm release name for Argo CD
  namespace  = var.namespace                 # Kubernetes namespace where Argo CD will be deployed
  repository = "https://argoproj.github.io/argo-helm" # Helm repository URL for Argo CD
  chart      = "argo_cd"                     # Helm chart name for Argo CD
  version    = var.chart_version             # Specific chart version to deploy

  # Load custom values from the local values.yaml file
  values = [
    file("${path.module}/values.yaml")
  ]

  create_namespace = true                    # Automatically create the namespace if it doesn't exist
}

# Deploy Argo CD applications using local Helm charts
resource "helm_release" "argo_apps" {
  name       = "${var.name}-apps"            # Helm release name for the Argo CD apps
  chart      = "${path.module}/charts"       # Path to the local Helm chart for applications
  namespace  = var.namespace                 # Kubernetes namespace for Argo CD apps (must match Argo CD namespace)
  create_namespace = false                   # Do not create namespace again, as it was created previously

  # Load custom application values from the local values.yaml file
  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [helm_release.argo_cd]        # Ensure Argo CD is deployed before deploying apps
}