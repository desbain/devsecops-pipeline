# 🛡️ Project 1 — DevSecOps CI/CD Pipeline

![Pipeline](https://img.shields.io/badge/Pipeline-GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS_%7C_ECR_%7C_VPC-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Alpine_Hardened-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Helm_%7C_RBAC-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Security](https://img.shields.io/badge/Security-Bandit_%7C_Trivy_%7C_Safety-FF0000?style=for-the-badge&logo=shield&logoColor=white)

> **A production-grade, security-first DevSecOps pipeline that automatically provisions AWS infrastructure with Terraform, scans code and containers, builds a hardened Docker image, and deploys a Flask application to Amazon EKS — with security gates at every stage.**

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Infrastructure — Terraform Modules](#infrastructure--terraform-modules)
- [Pipeline Stages](#pipeline-stages)
- [Security Controls](#security-controls)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup & Deployment](#setup--deployment)
- [Branch Strategy](#branch-strategy)
- [API Endpoints](#api-endpoints)
- [Compliance Mapping](#compliance-mapping)
- [Lessons Learned](#lessons-learned)

---

## 🏗️ Architecture Overview

```
Developer Push
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐ │
│  │ Terraform   │    │ App Pipeline│    │ Destroy         │ │
│  │ Plan/Apply  │    │ (6 stages)  │    │ (manual only)   │ │
│  └─────────────┘    └─────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
      │                     │
      ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    AWS Account                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                VPC (10.0.0.0/16)                     │  │
│  │  ┌─────────────────┐    ┌─────────────────────────┐  │  │
│  │  │  Public Subnets │    │    Private Subnets       │  │  │
│  │  │  (Load Balancer)│    │    (EKS Worker Nodes)    │  │  │
│  │  └─────────────────┘    └─────────────────────────┘  │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │           EKS Cluster (v1.34)                │   │  │
│  │  │   Pod 1 (Flask)          Pod 2 (Flask)       │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ ECR Registry │  │ S3 (TF State)│  │ DynamoDB (Lock)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Infrastructure — Terraform Modules

All infrastructure is provisioned as code using Terraform:

```
terraform/
├── main.tf              ← wires all modules together
├── variables.tf         ← input variable declarations
├── outputs.tf           ← infrastructure outputs
├── locals.tf            ← shared tags (Project, Environment, Owner)
├── dev.tfvars           ← environment values
└── modules/
    ├── vpc/             ← VPC, subnets, NAT gateway, route tables
    ├── security_groups/ ← EKS cluster and node security groups
    ├── iam/             ← IAM roles for cluster, nodes, GitHub Actions OIDC
    ├── eks/             ← EKS cluster, node group, CloudWatch logging
    └── ecr/             ← ECR repository, lifecycle policy, repo policy
```

### Terraform CI/CD Pipelines

| Workflow | Trigger | Action |
|----------|---------|--------|
| `terraform-plan.yml` | `feature/*` push, PR | Runs plan, posts as PR comment |
| `terraform-apply.yml` | Push to `main` | Applies infrastructure |
| `destroy.yml` | Manual only | Requires typing `DESTROY` |

---

## 🔄 Pipeline Stages

| Stage | Tool | Purpose | Blocks on Failure |
|-------|------|---------|-------------------|
| 1 — SAST Scan | Bandit | Static code analysis | ✅ Yes |
| 2 — Dependency Scan | Safety | CVE scan of pip packages | ✅ Yes |
| 3 — Docker Build | Docker | Multi-stage Alpine build | ✅ Yes |
| 4 — Container Scan | Trivy | Image vulnerability scan | ✅ Yes |
| 5 — Push to ECR | AWS ECR | Push to private registry | ✅ Yes |
| 6 — Deploy to EKS | Helm | Rolling deploy to Kubernetes | ✅ Yes |

---

## 🔐 Security Controls

### Infrastructure Layer
- VPC isolation — EKS nodes in private subnets
- IAM OIDC — GitHub Actions uses federation, no hardcoded keys
- Least-privilege IAM — separate roles for cluster, nodes, pipeline
- S3 state encryption + DynamoDB locking

### Application Layer
- SAST, dependency scanning, container scanning on every commit
- Non-root container, read-only filesystem, dropped capabilities
- emptyDir volume for Gunicorn worker temp files

### Kubernetes Layer
- RBAC scoped to `devsecops` namespace
- NetworkPolicy default-deny
- Resource limits, liveness and readiness probes

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Application | Python 3.12, Flask 3.1.3, Gunicorn 23.0.0 |
| Container | Docker Alpine, Multi-stage build |
| Registry | Amazon ECR (us-east-2) |
| Orchestration | Amazon EKS 1.34, Kubernetes |
| Deployment | Helm 4.1.4 |
| Infrastructure | Terraform 1.14.7 |
| CI/CD | GitHub Actions |
| Security Scanning | Bandit, Safety, Trivy |
| State Storage | AWS S3 + DynamoDB |
| Cloud | AWS (EKS, ECR, VPC, IAM, S3, DynamoDB) |

---

## 📁 Project Structure

```
devsecops-pipeline/
├── .github/workflows/
│   ├── pipeline.yml           # 6-stage app pipeline
│   ├── terraform-plan.yml     # Terraform plan on PRs
│   ├── terraform-apply.yml    # Terraform apply on main
│   └── destroy.yml            # Manual destroy
├── app/
│   ├── app.py                 # Flask app (3 endpoints)
│   ├── Dockerfile             # Hardened Alpine image
│   └── requirements.txt       # Pinned dependencies
├── helm/devsecops-app/
│   └── templates/
│       ├── deployment.yaml    # K8s Deployment
│       ├── service.yaml       # ClusterIP service
│       └── rbac.yaml          # Role + RoleBinding
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── locals.tf
│   ├── dev.tfvars
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security_groups/
│   │   ├── iam/
│   │   ├── eks/
│   │   └── ecr/
│   └── scripts/destroy.sh
└── README.md
```

---

## ✅ Prerequisites

| Tool | Version |
|------|---------|
| AWS CLI | 2.x |
| Terraform | 1.14.7+ |
| kubectl | 1.28+ |
| Helm | 4.x |
| Docker | 24.x |

---

## 🚀 Setup & Deployment

### 1. Clone and configure AWS
```bash
git clone https://github.com/desbain/devsecops-pipeline.git
cd devsecops-pipeline
aws configure  # region: us-east-2
```

### 2. Create Terraform state backend
```bash
aws s3api create-bucket \
  --bucket devsecops-terraform-state-<account-id> \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2
```

### 3. Initialize and apply Terraform
```bash
cd terraform
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### 4. Configure kubectl
```bash
aws eks update-kubeconfig --name devsecops-cluster --region us-east-2
kubectl get nodes
```

### 5. Add GitHub Secrets
| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | IAM access key |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key |
| `AWS_REGION` | `us-east-2` |
| `ECR_REGISTRY` | `<account-id>.dkr.ecr.us-east-2.amazonaws.com` |

### 6. Push to trigger pipeline
```bash
git push origin main
```

### 7. View the application
```bash
kubectl port-forward service/devsecops-app 8080:80 -n devsecops
# Open http://localhost:8080
```

### 8. Destroy infrastructure
```bash
cd terraform
bash scripts/destroy.sh  # Type DESTROY to confirm
```

---

## 🌿 Branch Strategy

```
main      ← Production. Protected. Requires PR.
develop   ← Integration. Full pipeline.
feature/* ← Working branches. Scans only.
```

---

## 🌐 API Endpoints

| Endpoint | Response |
|----------|----------|
| `/` | `{"status":"ok","message":"DevSecOps Pipeline App","version":"<sha>"}` |
| `/health` | `{"status":"healthy"}` |
| `/ready` | `{"status":"ready"}` |

---

## 📋 Compliance Mapping

| Control | Framework | Implementation |
|---------|-----------|---------------|
| AC-6 Least Privilege | NIST 800-53 | Non-root container, dropped capabilities, IAM scoping |
| AU-2 Audit Events | NIST 800-53 | CloudTrail, EKS control plane logs |
| CM-7 Least Functionality | NIST 800-53 | Alpine base, multi-stage build |
| CM-8 System Inventory | NIST 800-53 | Terraform state tracks all resources |
| RA-5 Vulnerability Scanning | NIST 800-53 | Bandit, Safety, Trivy on every commit |
| SC-7 Boundary Protection | NIST 800-53 | NetworkPolicy default-deny, VPC isolation |
| Req 11.3 | PCI-DSS | Vulnerability scanning before every deploy |
| § 164.312 | HIPAA | Access controls, audit logging, encryption |

---

## 💡 Lessons Learned

1. **Terraform module separation** — VPC, SG, IAM, EKS, ECR as independent modules allows independent auditing and reuse.
2. **IAM trust policies** — Cluster role needs `eks.amazonaws.com`, node role needs `ec2.amazonaws.com`. Swapping causes silent failures.
3. **Terraform state imports** — `terraform import` brings manually created resources under state management without recreating them.
4. **readOnlyRootFilesystem + Gunicorn** — Requires `emptyDir` volume for `/tmp` since Gunicorn needs to write worker temp files.
5. **ECR tag mutability** — Use `MUTABLE` during development, switch to `IMMUTABLE` with SHA-only tags in production.
6. **OIDC vs access keys** — GitHub Actions OIDC tokens are short-lived and repo-scoped — far more secure than static IAM keys.

---

## 👤 Author

**George Awa** — DevSecOps Engineer | GRC & Cloud Security

[![GitHub](https://img.shields.io/badge/GitHub-desbain-181717?style=flat&logo=github)](https://github.com/desbain)

---

## 📦 Related Projects

| Project | Status |
|---------|--------|
| Project 2 — AWS Security Monitoring (GuardDuty + Lambda) | 🔜 Next |
| Project 3 — Hardened EKS (Checkov + ArgoCD) | 📋 Planned |
| Project 4 — Linux SME Lab | 📋 Planned |
| Project 5 — Docker Mastery | 📋 Planned |
| ShieldOps — Capstone Platform | 📋 Planned |
