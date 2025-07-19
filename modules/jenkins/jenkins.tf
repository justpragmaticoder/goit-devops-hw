# Deploy Jenkins via Helm chart
resource "helm_release" "jenkins" {
  name             = "jenkins"                           # Helm release name
  namespace        = "jenkins"                           # Kubernetes namespace for Jenkins
  repository       = "https://charts.jenkins.io"         # Helm chart repository for Jenkins
  chart            = "jenkins"                           # Chart name
  version          = "5.8.27"                            # Specific chart version
  create_namespace = true                                 # Create namespace if it doesn't exist

  values = [
    file("${path.module}/values.yaml")                   # Custom values file for Jenkins configuration
  ]
}

# Create a default StorageClass using AWS EBS (gp3) with CSI driver
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"  # Mark this as the default storage class
    }
  }

  storage_provisioner = "ebs.csi.aws.com"                 # CSI driver for AWS EBS
  reclaim_policy       = "Delete"                         # Delete volume when PVC is deleted
  volume_binding_mode  = "WaitForFirstConsumer"          # Delay provisioning until a pod uses the PVC

  parameters = {
    type = "gp3"                                           # EBS volume type
  }
}

# Create a Kubernetes ServiceAccount for Jenkins Kaniko builds with IAM role annotation
resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"                              # Service account name
    namespace = "jenkins"                                 # Must match Jenkins namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn  # Link to IAM role
    }
  }
  depends_on = [
    helm_release.jenkins                                  # Ensure Jenkins is deployed first
  ]
}

# IAM Role for Jenkins Kaniko pod to access ECR via OIDC
resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({                       # Trust policy for IRSA (IAM Role for Service Accounts)
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn               # OIDC provider ARN from EKS
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins-sa"
          }
        }
      }
    ]
  })
}

# IAM Policy allowing Jenkins Kaniko to push to ECR
resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories"
        ],
        Resource = "*"                                     # Allow access to all ECR repositories
      }
    ]
  })
}