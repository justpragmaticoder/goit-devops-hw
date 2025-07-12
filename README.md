# Terraform & Helm AWS Infrastructure – Lesson 07

A **modular Terraform stack** that provisions a VPC, an ECR repository, an EKS cluster, and a secure S3 + DynamoDB backend for remote state — plus a **Helm chart** to deploy a Django application into that cluster. Built for the GoIT DevOps course (lesson 7) and ready to be reused in any AWS account.

---

## Table of Contents

1. [Project Layout](#project-layout)  
2. [Features](#features)  
3. [Prerequisites](#prerequisites)  
4. [Quick Start](#quick-start)  
5. [Remote State](#remote-state)  
6. [Helm Chart](#helm-chart)  
7. [Customisation](#customisation)  
8. [Outputs](#outputs)  
9. [Security](#security)  
10. [Cleanup](#cleanup)

---

## Project Layout

```text
lesson-7/
├── charts/                   # Helm chart for the Django application
│   ├── Chart.yaml            # Chart metadata (apiVersion, name, version, appVersion)
│   ├── values.yaml           # Default values (image, service, config, etc.)
│   └── templates/            # Kubernetes manifest templates
│       ├── configmap.yaml    # Renders a ConfigMap from your env vars
│       ├── deployment.yaml   # Renders the Deployment for Django pods
│       ├── hpa.yaml          # Renders an HPA to auto-scale your pods
│       └── service.yaml      # Renders a Service to expose the app
├── env/                      # Environment-specific overrides for Helm values
│   └── values-dev.yaml       # e.g. development overrides
│   └── values-prod.yaml      # e.g. production overrides
├── modules/                  # Terraform modules encapsulating AWS infra
│   ├── ecr/                  # Module to create an ECR repo
│   ├── s3-backend/           # Module to provision S3 & DynamoDB for tfstate
│   ├── vpc/                  # Module to build your VPC & networking
│   └── eks/                  # Module to deploy an EKS cluster
├── .gitignore                # Files & dirs to ignore in Git
├── backend.tf                # Terraform S3 backend config (remote state bucket + lock)
├── main.tf                   # Root module: wires up ecr, s3-backend, vpc & eks
├── variables.tf              # Root-level input variable definitions & defaults
└── outputs.tf                # Root-level outputs exposing module outputs
```

---

## Features

| Module / Component      | Purpose                                           | Key Resources & Notes                                                                                  |
|-------------------------|---------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| **VPC**                 | Three-AZ network split into public & private tiers| 1 VPC, 3 public + 3 private subnets, route tables, Internet Gateway                                    |
| **ECR**                 | Private container registry w/ vuln. scanning      | Repository `lesson-7-ecr` (or override via `ecr_name`), scan-on-push                                    |
| **EKS**                 | Managed Kubernetes control plane + nodes          | Uses `terraform-aws-modules/eks` (v20.x), public & private endpoint access, managed node group (t3.medium) |
| **State backend**       | Reliable & shared Terraform state                 | S3 bucket `vasyl-p-terraform-states-lesson-7`, DynamoDB table `terraform-locks`, versioning & encryption enabled |
| **Helm Chart**          | Deploy Django app into EKS                        | `charts/` folder with configurable templates, supports `env/` overrides                                |

### Default CIDR Map

```text
VPC         10.0.0.0/16
Public AZs  10.0.1.0/24  10.0.2.0/24  10.0.3.0/24
Private AZs 10.0.4.0/24  10.0.5.0/24  10.0.6.0/24
Region      us-west-2  (AZs a, b, c)
```

_All CIDRs, AZs, names and other parameters are fully overrideable via root variables._

---

## Prerequisites

- **Terraform ≥ 1.0**  
- **Helm ≥ 3.0**  
- **AWS CLI** configured with an IAM user/role that can create VPCs, ECR, EKS, S3 and DynamoDB  
- An AWS account (default region is **us-west-2**)

---

## Quick Start

1. **Clone and switch to lesson-7**  
   ```bash
   git clone git@github.com:justpragmaticoder/goit-devops-hw.git
   cd goit-devops-hw
   git checkout lesson-7
   ```

2. **Initialize Terraform**  
   ```bash
   terraform init
   ```

3. **Review plan & apply**  
   ```bash
   terraform plan
   terraform apply
   ```

4. **Configure kubectl & Helm**  
   ```bash
   aws eks update-kubeconfig --name $(terraform output -raw cluster_name)
   helm repo add local file://./charts
   ```

5. **Deploy Django app via Helm**  
   ```bash
   # for dev:
   helm upgrade --install django-app local/django-app      --values env/values-dev.yaml
   ```

> Add `-auto-approve` to your Terraform commands for non-interactive CI runs.

---

## Remote State

Terraform remote state is configured in **backend.tf**:

```hcl
terraform {
  backend "s3" {
    bucket         = "vasyl-p-terraform-states-lesson-7"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

To reconfigure or change bucket/region:

```bash
terraform init -reconfigure
```

---

## Helm Chart

Your Django Helm chart lives in `charts/`, with:

- `Chart.yaml` — metadata  
- `values.yaml` — default settings (image repo/tag, service type/port, config)  
- `templates/` — manifests for Deployment, Service, HPA, ConfigMap  

Override any value per-environment with files in `env/`:

```bash
# Production example
helm upgrade --install django-app local/django-app   --values env/values-prod.yaml
```

---

## Customisation

Pass variables via a `*.tfvars` file or `-var` CLI flags.

| Category          | Variable                                 | Default                                    |
|-------------------|------------------------------------------|--------------------------------------------|
| **Network**       | `vpc_cidr_block`                         | `10.0.0.0/16`                              |
|                   | `public_subnets` / `private_subnets`     | see [Default CIDR Map](#default-cidr-map)  |
|                   | `availability_zones`                     | `["us-west-2a","us-west-2b","us-west-2c"]` |
|                   | `vpc_name`                               | `vpc`                                      |
| **ECR**           | `ecr_name`                               | `lesson-7-ecr`                             |
|                   | `scan_on_push`                           | `true`                                     |
| **EKS**           | `cluster_name`                           | `lesson-7-eks`                             |
|                   | `cluster_version`                        | `1.29`                                     |
| **State backend** | `s3_bucket_name` / `dynamodb_table_name` | same as in backend.tf                      |

Example `custom.tfvars`:

```hcl
vpc_cidr_block  = "192.168.0.0/16"
public_subnets  = ["192.168.1.0/24","192.168.2.0/24","192.168.3.0/24"]
private_subnets = ["192.168.101.0/24","192.168.102.0/24","192.168.103.0/24"]
vpc_name        = "demo-vpc"
cluster_name    = "demo-eks"
ecr_name        = "demo-ecr"
```

---

## Outputs

After `terraform apply`, run:

```bash
terraform output -json | jq
```

Notable outputs:

- `vpc_id`                 — ID of the created VPC  
- `public_subnets`         — List of public subnet IDs  
- `private_subnets`        — List of private subnet IDs  
- `ecr_repository_url`     — URI for `docker build && docker push`  
- `cluster_id` / `cluster_endpoint` — EKS cluster details  

---

## Security

- **S3 versioning + AES-256 encryption** protect your Terraform state  
- **DynamoDB state locking** prevents concurrent applies  
- **Private subnets** isolate non-public resources  
- **ECR image scanning** helps catch CVEs early  
- **Cluster endpoint private access** keeps API secure within your VPC  

---

## Cleanup

```bash
terraform destroy
```

> ⚠️ This removes **all** resources, including the state bucket and lock table. Make sure you have backups of any state or data you need.

---