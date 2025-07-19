# 🚀 GoIT DevOps Project: CI/CD with Terraform, Jenkins & Argo CD on AWS

This project provisions a complete Kubernetes-based CI/CD infrastructure on AWS using **Terraform**, **Helm**, **Jenkins**, and **Argo CD**. It automates infrastructure deployment, container image builds with Jenkins + Kaniko, and GitOps-style app delivery with Argo CD.

---

## 📁 Project Structure

```text
goit-devops-hw/
├── modules/                 # Terraform modules
│   ├── eks/                # EKS cluster
│   ├── vpc/                # VPC and subnets
│   ├── ecr/                # ECR registry
│   ├── s3-backend/         # Remote state backend (S3 + DynamoDB)
│   ├── jenkins/            # Jenkins with IRSA & StorageClass
│   └── argo_cd/            # Argo CD with Helm apps
├── charts/                 # Helm chart for Django app
├── Jenkinsfile             # CI pipeline (Docker build & tag update)
└── main.tf / outputs.tf    # Root Terraform configs
```

---

## ✅ Features

- ✅ **EKS cluster** with public subnets
- ✅ **Jenkins on Kubernetes** with EBS dynamic volumes
- ✅ **Kaniko** for building/pushing images securely
- ✅ **IRSA** (IAM Roles for Service Accounts) for secure ECR access
- ✅ **Argo CD** for GitOps deployments
- ✅ **Remote Terraform state** (S3 + DynamoDB lock)

---

## ⚙️ Prerequisites

- AWS CLI & credentials with admin access
- Terraform >= 1.3
- kubectl + AWS IAM Authenticator
- Helm >= 3.0
- EKS cluster OIDC enabled

---

## 🚀 Deployment Steps

```bash
# 1. Clone the project
$ git clone -b lesson-8-9 https://github.com/justpragmaticoder/goit-devops-hw.git
$ cd goit-devops-hw

# 2. Initialize Terraform
$ terraform init

# 3. Review and apply infrastructure
$ terraform apply -auto-approve

# 4. Get access to EKS cluster
$ aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks

# 5. Verify Jenkins and ArgoCD
$ kubectl get svc -n jenkins
$ kubectl get svc -n argocd
```

---

## 🧪 Jenkins CI/CD Pipeline

The Jenkinsfile defines a 2-stage pipeline:

1. **Build & Push Image** - Jenkins + Kaniko builds Docker image and pushes to ECR  
2. **Update Helm values.yaml** - Git-clones the repo, changes tag, and pushes to `main`

```groovy
pipeline {
  agent { kubernetes { ... } }
  stages {
    stage('Build & Push') { ... }
    stage('Update Tag')  { ... }
  }
}
```

---

## 🔁 Argo CD GitOps

Argo CD continuously syncs the Helm release from the Git repo. Whenever the `values.yaml` file is updated with a new image tag, ArgoCD applies the update automatically.

```yaml
applications:
  - name: example-app
    source:
      repoURL: https://github.com/justpragmaticoder/goit-devops-hw.git
      path: django-chart
      targetRevision: main
```

---

## 🔐 Access Credentials

```bash
# Argo CD Admin Password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Jenkins Admin:
Username: admin
Password: changeme123
```

---

## 🧰 Clean Up

```bash
terraform destroy -auto-approve
```

---

## 📊 CI/CD Architecture (Text Diagram)

```text
GitHub Repo
   │
   └── push (Jenkinsfile) ─▶ Jenkins (on EKS)
                            └── Kaniko → ECR
                                 └── Tag updated in Helm chart
                                        │
                                        ▼
                                Argo CD syncs → K8s deploy
```

---

## 💻 Author

- GitHub: [justpragmaticoder](https://github.com/justpragmaticoder)
- GoIT DevOps Course
