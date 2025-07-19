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

## 🛠 How to apply Terraform

```bash
# 1. Initialize Terraform
terraform init

# 2. Review the execution plan
terraform plan

# 3. Apply infrastructure changes
terraform apply -auto-approve
```

> 📦 After applying, the EKS cluster, Jenkins, Argo CD, and other services will be provisioned.

---

## 🔧 How to check a Jenkins Job

1. Get the Jenkins service endpoint:
   ```bash
   kubectl get svc -n jenkins
   ```
2. Open the LoadBalancer IP in your browser:
   ```
   http://<JENKINS-EXTERNAL-IP>
   ```
3. Log in:
   ```
   Username: admin
   Password: changeme123
   ```
4. Find and run the Job (e.g., `seed-job` or `goit-django-docker`).  
5. Check the build logs under **Console Output**.

> ⚙️ The job will build the Docker image, push it to ECR, and update the Helm chart tag in GitHub.

---

## 🎯 How to see the result in Argo CD

1. Get the Argo CD service endpoint:
   ```bash
   kubectl get svc -n argocd
   ```
2. Open the LoadBalancer IP in your browser:
   ```
   https://<ARGOCD-EXTERNAL-IP>
   ```
3. Log in:
   ```
   Username: admin
   Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
   ```
4. In the Argo CD UI, find your application (e.g., `example-app`) and verify:
   - Status is **Healthy**  
   - Sync status is **Synced**  
   - Image tag matches the version pushed by Jenkins  

---

## 🧪 Jenkins CI/CD Pipeline

The Jenkinsfile defines a 2-stage pipeline:

1. **Build & Push Image** - Jenkins + Kaniko builds Docker image and pushes to ECR  
2. **Update Helm values.yaml** - Git-clones the repo, updates the tag, and pushes to `main`  

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

Argo CD continuously syncs the Helm release from the Git repository. Whenever `values.yaml` is updated with a new image tag, Argo CD applies the change automatically.

```yaml
applications:
  - name: example-app
    source:
      repoURL: https://github.com/justpragmaticoder/goit-devops-hw.git
      path: charts
      targetRevision: main
```

---

## 🔐 Access Credentials

```bash
# Argo CD Admin Password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Jenkins Admin Credentials:
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
                                Argo CD syncs → Kubernetes deploy
```

---

## 💻 Author

- GitHub: [justpragmaticoder](https://github.com/justpragmaticoder)  
- GoIT DevOps Course  
