# GoIT DevOps Final Project

## Project Description

This repository contains infrastructure-as-code automation for deploying a Django application on AWS using Terraform and Helm, with CI/CD pipelines managed by Jenkins and Argo CD.

- **Resources provisioned:** S3 bucket and DynamoDB table for Terraform state and locking, VPC, ECR repository, EKS Kubernetes cluster, and RDS/Aurora database.
- **Application deployment:** Django app container is built and deployed to the EKS cluster via a Helm chart with autoscaling, LoadBalancer service, and ConfigMap support.

---

## Project Structure

```
goit-devops-hw/
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── modules/
│   ├── vpc/
│   ├── s3-backend/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   ├── argo_cd/
│   └── rds/
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── configmap.yaml
            ├── deployment.yaml
            ├── hpa.yaml
            └── service.yaml
```

---

## Prerequisites

- AWS account with a configured profile in `~/.aws/credentials`.
- Installed tools:
  - [Terraform](https://www.terraform.io/downloads)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/)
  - [Helm](https://helm.sh/docs/intro/install/)
  - [Docker](https://docs.docker.com/get-docker/)

> **Note:** If using multiple AWS CLI profiles, add `--profile <profile_name>` to AWS commands.

---

## Terraform Commands

```bash
terraform init            # Initialize project, backend, and modules
terraform plan            # Show planned changes
terraform apply           # Apply infrastructure changes
terraform destroy -lock=false  # Destroy all resources without locking errors
terraform init -upgrade   # Reinitialize with provider/module upgrades
```

---

## Import Existing Resources

If resources like the S3 bucket, DynamoDB table, or ECR repository were created manually, import them into Terraform state:

```bash
aws s3api create-bucket --bucket <your-bucket> --region <region> --create-bucket-configuration LocationConstraint=<region>
aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region <region>
aws ecr create-repository --repository-name <repo-name> --region <region>

terraform import module.s3-backend.aws_s3_bucket.terraform_state <your-bucket>
terraform import module.s3-backend.aws_dynamodb_table.terraform_locks terraform-locks
terraform import module.ecr.aws_ecr_repository.this <repo-name>
```

### EKS and KMS Imports

```bash
terraform import 'module.eks.module.eks.module.kms.aws_kms_alias.this["cluster"]' alias/eks/<cluster-name>
terraform import 'module.eks.module.eks.aws_cloudwatch_log_group.this[0]' /aws/eks/<cluster-name>/cluster
terraform import 'module.eks.module.eks.aws_iam_openid_connect_provider.oidc_provider[0]' <oidc-provider-arn>
```

---

## AWS CLI Configuration

Configure access for Terraform and kubectl:

```bash
export AWS_ACCESS_KEY_ID=<your-key-id>
export AWS_SECRET_ACCESS_KEY=<your-secret>
export AWS_DEFAULT_REGION=<region>
aws sts get-caller-identity
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

---

## Docker & ECR

Build and push Django Docker image to ECR:

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com

docker build -t django-app:<tag> django/
docker tag django-app:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/django-app:<tag>
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/django-app:<tag>
```

---

## Deploy Application via Helm

```bash
cd charts/django-app
helm install django-app .
# or upgrade
helm upgrade django-app .
```

---

## Local PostgreSQL (Optional)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-postgres bitnami/postgresql
helm upgrade django-app .
```

---

## CI/CD: Jenkins & Argo CD

1. **Jenkins:** Pipeline defined in `modules/jenkins/` using Helm values. Trigger on Git push or manual run.
2. **Argo CD:** Application manifests in `modules/argo_cd/charts`. Webhook integration for auto-sync.

---

## Deployment and Validation

1. **Deploy Infrastructure**

   Execute:

   ```bash
   terraform apply
   ```

2. **Verify Resource Status**

   Check pods and services:

   ```bash
   kubectl get all -n jenkins
   kubectl get all -n argocd
   kubectl get all -n monitoring
   ```

3. **Access Services**

   - **Jenkins:**

     ```bash
     kubectl port-forward svc/jenkins 8080:8080 -n jenkins
     ```

     Access at `http://localhost:8080`.

   - **Argo CD:**

     ```bash
     kubectl port-forward svc/argocd-server 8081:443 -n argocd
     ```

     Access at `https://localhost:8081`.

4. **Monitoring Metrics**

   - **Grafana:**
     ```bash
     kubectl port-forward svc/grafana 3000:80 -n monitoring
     ```
     Access Grafana dashboard at `http://localhost:3000` to view cluster and application metrics.

> ⚠️ **Cost Awareness:** Unused cloud resources can incur significant costs. Always destroy resources after validation:
>
> ```bash
> terraform destroy -lock=false
> ```
>
> **Important:** Dropping the entire infrastructure will also remove the S3 bucket and DynamoDB table used for state storage. To re-deploy, ensure you recreate or import the backend resources first.

---

## Common Issues & Troubleshooting

| Error                                | Solution                                                   |
|--------------------------------------|------------------------------------------------------------|
| S3 BucketNotEmpty                    | Empty or versioned objects before S3 bucket deletion.      |
| DynamoDB ResourceNotFoundException   | Use `terraform destroy -lock=false` if lock table removed. |
| ECR RepositoryAlreadyExistsException | Import existing repo into Terraform state.                 |
| EKS ClusterAlreadyExistsException    | Import cluster resources into Terraform state.             |

---

## Module Descriptions

- **s3-backend:** Manages S3 bucket and DynamoDB table for Terraform state.
- **vpc:** Creates VPC with public/private subnets, NAT gateways, and routing.
- **ecr:** Sets up ECR repository for container images.
- **eks:** Deploys EKS cluster with CSI driver, OIDC provider, and CloudWatch logging.
- **jenkins:** Installs Jenkins via Helm with predefined pipeline for Docker build and Terraform.
- **argo\_cd:** Configures Argo CD for continuous deployment of Helm charts.
- **rds:** Provisions RDS or Aurora cluster with backup retention and deletion protection.

---

## RDS Module Example

```hcl
module "rds" {
  source                        = "./modules/rds"
  name                          = "myapp-db"
  use_aurora                    = true
  aurora_instance_count         = 2
  aurora_replica_count          = 1
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  engine                        = "postgres"
  engine_version                = "14.7"
  parameter_group_family_rds    = "postgres14"

  instance_class                = "db.t3.medium"
  allocated_storage             = 20
  db_name                       = "myapp"
  username                      = "postgres"
  password                      = "admin123AWS23"
  subnet_private_ids            = module.vpc.private_subnets
  subnet_public_ids             = module.vpc.public_subnets
  publicly_accessible           = true
  vpc_id                        = module.vpc.vpc_id
  multi_az                      = true
  backup_retention_period       = 7
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

---

## RDS Module Variables

| Variable                         | Type         | Description                             | Default/Example       |
|----------------------------------|--------------|-----------------------------------------|-----------------------|
| name                             | string       | Name of the DB instance or cluster      | "myapp-db"            |
| use\_aurora                      | bool         | true for Aurora, false for standard RDS | false                 |
| aurora\_instance\_count          | number       | Number of instances in Aurora cluster   | 2                     |
| aurora\_replica\_count           | number       | Number of Aurora replicas               | 1                     |
| engine\_cluster                  | string       | Aurora engine type                      | "aurora-postgresql"   |
| engine\_version\_cluster         | string       | Aurora engine version                   | "15.3"                |
| parameter\_group\_family\_aurora | string       | Aurora parameter group family           | "aurora-postgresql15" |
| engine                           | string       | Standard RDS engine                     | "postgres"            |
| engine\_version                  | string       | Standard RDS engine version             | "14.7"                |
| parameter\_group\_family\_rds    | string       | RDS parameter group family              | "postgres14"          |
| instance\_class                  | string       | Instance type                           | "db.t3.micro"         |
| allocated\_storage               | number       | Storage size in GB                      | 20                    |
| db\_name                         | string       | Database name                           | "myapp"               |
| username                         | string       | Database master username                | "postgres"            |
| password                         | string       | Database master password (sensitive)    |                       |
| vpc\_id                          | string       | VPC ID                                  |                       |
| subnet\_private\_ids             | list(string) | List of private subnet IDs              |                       |
| subnet\_public\_ids              | list(string) | List of public subnet IDs               |                       |
| publicly\_accessible             | bool         | Provide public access to DB             | false                 |
| multi\_az                        | bool         | Deploy across multiple AZs              | false                 |
| backup\_retention\_period        | number       | Backup retention days                   | 7                     |
| parameters                       | map(string)  | Additional DB parameters                | {}                    |
| tags                             | map(string)  | Tags applied to all resources           | {}                    |

---

