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
│   ├── argo_cd/            # Argo CD with Helm apps
│   └── rds/                # RDS / Aurora database module
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

## 🗄️ RDS / Aurora Module Example

Below is a **minimal but complete** example that provisions a two-node **Aurora PostgreSQL 15.3** cluster.  
Set `use_aurora = false` to create a single-instance RDS PostgreSQL 17.2 instead.

```hcl
module "rds" {
  source = "./modules/rds"

  # 1️⃣ Naming & toggle
  name            = "myapp-db"
  use_aurora      = true          # true = Aurora, false = RDS
  aurora_instance_count = 2       # 1 writer + 1 reader

  # 2️⃣ Engine / version
  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.3"
  engine                 = "postgres"
  engine_version         = "17.2"

  # 3️⃣ Sizing
  instance_class    = "db.t3.medium"
  allocated_storage = 20          # Standard RDS only

  # 4️⃣ Networking
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  subnet_public_ids   = module.vpc.public_subnets
  publicly_accessible = true
  multi_az            = true      # Standard RDS only

  # 5️⃣ Credentials & DB name
  db_name  = "myapp"
  username = "postgres"
  password = "ChangeMeSecure1!"

  # 6️⃣ Backup & parameters
  backup_retention_period = 7
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  # 7️⃣ Tags
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

---

## 📚 Variable Reference

| Variable | Type / Default | Description |
|----------|----------------|-------------|
| `name` | *string* | Prefix for all DB resources. |
| `use_aurora` | *bool* = `false` | `true` → deploy Aurora cluster, `false` → single RDS. |
| `aurora_instance_count` | *number* = `2` | Total Aurora instances (≥2 for HA). |
| `aurora_replica_count` | *number* = `1` | Number of Aurora reader replicas (alternative to `aurora_instance_count`). |
| `engine_cluster` | *string* = `aurora-postgresql` | Aurora engine (`aurora-mysql`, `aurora-postgresql`). |
| `engine_version_cluster` | *string* = `15.3` | Aurora engine version. |
| `parameter_group_family_aurora` | *string* = `aurora-postgresql15` | Parameter group family for Aurora. |
| `engine` | *string* = `postgres` | Engine for standard RDS (`mysql`, `postgres`, etc.). |
| `engine_version` | *string* = `14.7` | Engine version for standard RDS. |
| `parameter_group_family_rds` | *string* = `postgres15` | Parameter group family for RDS. |
| `instance_class` | *string* = `db.t3.micro` | DB instance size for both Aurora & RDS. |
| `allocated_storage` | *number* = `20` | Storage in GB (standard RDS only). |
| `db_name` | *string* | Initial database to create. |
| `username` | *string* | Master DB username. |
| `password` | *string* **(sensitive)** | Master DB password. |
| `vpc_id` | *string* | VPC ID where subnets reside. |
| `subnet_private_ids` | *list(string)* | Private subnet IDs. |
| `subnet_public_ids` | *list(string)* | Public subnet IDs (if `publicly_accessible = true`). |
| `publicly_accessible` | *bool* = `false` | Expose DB publicly. |
| `multi_az` | *bool* = `false` | Enable Multi-AZ for standard RDS. |
| `backup_retention_period` | *string* | Days to retain automated backups. |
| `parameters` | *map(string)* | Custom engine parameters (key → value). |
| `tags` | *map(string)* | Tags applied to all DB resources. |

---

## 🔄 How to Change DB Type, Engine, Instance Class, etc.

| Scenario | Settings to Adjust |
|----------|-------------------|
| **Switch Aurora → RDS** | `use_aurora = false`, update `engine`, `engine_version`, `instance_class`, remove/ignore `aurora_instance_count`. |
| **Change Aurora from Postgres to MySQL** | `engine_cluster = "aurora-mysql"`, pick a compatible `engine_version_cluster`, update `parameter_group_family_aurora`. |
| **Upgrade Engine Version** | Increment `engine_version` (RDS) or `engine_version_cluster` (Aurora). |
| **Resize Instances** | Modify `instance_class` for both; adjust `aurora_instance_count` / `aurora_replica_count` for scaling reads. |
| **Increase Storage (standard RDS)** | Raise `allocated_storage`. Aurora storage auto‑scales. |
| **Make DB Private** | `publicly_accessible = false`, ensure private subnets and SG allow only internal CIDRs. |

> Tip: After changing variables run `terraform plan` to preview updates, then `terraform apply`.

---

*This README focuses on the RDS/Aurora module. For full CI/CD setup details (EKS, Jenkins, Argo CD), see earlier sections of the file.*

## 💻 Author

- GitHub: [justpragmaticoder](https://github.com/justpragmaticoder)  
- GoIT DevOps Course  
