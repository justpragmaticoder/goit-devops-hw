# Terraform AWS Infrastructure – Homework 05

A **modular Terraform stack** that provisions a VPC, an ECR repository, and a secure S3 + DynamoDB backend for remote state. Built for the GoIT DevOps course (homework 05) and ready to be reused in any AWS account.

---

## Table of Contents

1. [Project Layout](#project-layout)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Remote State](#remote-state)
6. [Customisation](#customisation)
7. [Outputs](#outputs)
8. [Security](#security)
9. [Cleanup](#cleanup)
10. [License](#license)

---

## Project Layout

```text
lesson-5/
├── main.tf                  # Root module glue
├── backend.tf               # Optional S3 backend (commented)
└── modules/
    ├── ecr/                 # Amazon ECR repository
    ├── s3-backend/          # S3 bucket + DynamoDB for state & locking
    └── vpc/                 # VPC, subnets, routing, IGW
```

---

## Features

| Module            | Goal                                                | Key Resources                                                                                                    |
|-------------------|-----------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| **VPC**           | Three‑AZ network split into public & private tiers  | 1 VPC, 3 public + 3 private subnets, route tables, IGW                                                           |
| **ECR**           | Private container registry with vulnerability scans | Repository `lesson5-ecr` / scan‑on‑push = `true`                                                                 |
| **State backend** | Reliable & shared Terraform state                   | S3 bucket `vasyl-p-terraform-states-lesson-5`, DynamoDB table `terraform-locks`, versioning & encryption enabled |

### Default CIDR Map

```text
VPC         10.0.0.0/16
Public AZs  10.0.1.0/24  10.0.2.0/24  10.0.3.0/24
Private AZs 10.0.4.0/24  10.0.5.0/24  10.0.6.0/24
Region      us‑west‑2  (AZs a, b, c)
```

All CIDRs and AZs are overrideable via variables.

---

## Prerequisites

- **Terraform ≥ 1.0**
- **AWS CLI** configured with an IAM user/role that can create VPCs, ECR, S3 and DynamoDB
- An AWS account (default region is **us‑west‑2**)

---

## Quick Start

```bash
# 1 Clone the repo via SSH
$ git clone git@github.com:justpragmaticoder/goit-devops-hw.git
$ git checkout lesson-5

# 2 Initialise providers & modules
$ terraform init

# 3 Review the execution plan
$ terraform plan

# 4 Apply the configuration
$ terraform apply

# 5 Destroy everything when finished
$ terraform destroy
```

Add `-auto-approve` to `terraform apply`/`destroy` for non‑interactive CI runs.

---

## Remote State

Local state is fine for experiments, but teams should store state centrally. Adjust the bucket or region if needed, and re‑initialise:

```hcl
terraform {
  backend "s3" {
    bucket         = "vasyl-p-terraform-states-lesson-5"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

```bash
$ terraform init -reconfigure
```

---

## Customisation

Pass variables via a `*.tfvars` file or `-var` CLI flags.

| Category          | Variable                                 | Purpose                | Default                                    |
|-------------------|------------------------------------------|------------------------|--------------------------------------------|
| **Network**       | `vpc_cidr_block`                         | Base VPC CIDR          | `10.0.0.0/16`                              |
|                   | `public_subnets` / `private_subnets`     | CIDRs per subnet       | see [map](#default-cidr-map)               |
|                   | `availability_zones`                     | Spread across AZs      | `["us-west-2a","us-west-2b","us-west-2c"]` |
|                   | `vpc_name`                               | Tag prefix             | `vpc`                                      |
| **ECR**           | `ecr_name`                               | Registry name          | `lesson5-ecr`                              |
|                   | `scan_on_push`                           | Vulnerability scanning | `true`                                     |
| **State backend** | `s3_bucket_name` / `dynamodb_table_name` | Re‑use existing names  | as above                                   |

Example override file:

```hcl
# custom tfvars
vpc_cidr_block  = "192.168.0.0/16"
public_subnets  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
private_subnets = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
vpc_name        = "demo"
```

---

## Outputs

Run `terraform output` at any time to retrieve:

- `` – VPC identifier
- ``** / **`` – lists of subnet IDs
- `` – URI for `docker push`
- ``** & **`` – backend resource names

All outputs are also available programmatically:

```bash
terraform output -json | jq
```

---

## Security

- S3 **versioning + AES‑256 encryption** protect the state file
- DynamoDB **state locking** prevents simultaneous `apply` runs
- **Private subnets** isolate internal services from the Internet
- **ECR image scanning** helps catch CVEs early

---

## Cleanup

```bash
terraform destroy
```

⚠️  This removes **all** resources created by the stack, including the state bucket and lock table if they were created here.  Make sure you have a copy of the state file somewhere safe first.

---

## License

This project is released under the **MIT License**.

