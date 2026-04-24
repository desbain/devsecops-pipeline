# DevSecOps CI/CD Pipeline — Python Flask on Amazon EKS

> **Portfolio Project** | George Awa, CISSP | DevSecOps Engineer

A production-grade DevSecOps pipeline that builds, scans, and deploys a Python Flask application to Amazon EKS using GitHub Actions. Every commit triggers automated security gates — no vulnerable code reaches production.

---

## Architecture Overview

```
Developer Push
      │
      ▼
┌─────────────────────────────────────────────────────┐
│              GitHub Actions Pipeline                 │
│                                                     │
│  [1] SAST Scan        ← Bandit (Python)             │
│       │                                             │
│  [2] Dependency Scan  ← Safety                      │
│       │                                             │
│  [3] Docker Build     ← python:3.12-slim            │
│       │                                             │
│  [4] Image Scan       ← Trivy (CRITICAL/HIGH block) │
│       │                                             │
│  [5] Push to ECR      ← Amazon Elastic Container    │
│       │                  Registry                   │
│  [6] Deploy to EKS    ← Helm + kubectl              │
└─────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────┐
│              Amazon EKS Cluster                      │
│                                                     │
│  Namespace: devsecops                               │
│  ├── Deployment (2 replicas, non-root)              │
│  ├── Service (ClusterIP)                            │
│  ├── Ingress (ALB)                                  │
│  ├── NetworkPolicy (zero-trust)                     │
│  ├── RBAC (least-privilege ServiceAccount)          │
│  └── HPA (auto-scales 2–5 replicas)                │
└─────────────────────────────────────────────────────┘
```

---

## Security Controls

| Layer | Control | Tool |
|-------|---------|------|
| Code | Static analysis — blocks medium+ severity issues | Bandit |
| Dependencies | Known CVE scan on requirements.txt | Safety |
| Container | Image vulnerability scan — blocks CRITICAL/HIGH CVEs | Trivy |
| Registry | Scan on push enabled | Amazon ECR |
| Runtime | Non-root user, read-only filesystem, dropped capabilities | Dockerfile + Helm |
| Network | Zero-trust NetworkPolicy — deny all, allow only required traffic | Kubernetes |
| Access | Least-privilege RBAC ServiceAccount per namespace | Kubernetes |
| Secrets | No hardcoded secrets — GitHub encrypted secrets + AWS Secrets Manager | GitHub Actions |
| Infrastructure | Remote state with S3 + DynamoDB lock | Terraform |

---

## Project Structure

```
devsecops-pipeline/
├── app/
│   ├── app.py               # Flask application
│   ├── requirements.txt     # Python dependencies
│   ├── Dockerfile           # Hardened container image
│   └── .dockerignore
├── .github/
│   └── workflows/
│       └── pipeline.yml     # Full CI/CD pipeline with security gates
├── helm/
│   └── devsecops-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml   # Pod security context enforced
│           ├── service.yaml
│           └── rbac.yaml         # ServiceAccount + Role + RoleBinding
├── k8s/
│   └── network-policy.yaml  # Zero-trust NetworkPolicy
├── terraform/
│   ├── main.tf              # EKS cluster + VPC + ECR
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

---

## Prerequisites

- AWS account with IAM user/role permissions for EKS, ECR, VPC
- GitHub repository with Actions enabled
- Tools installed locally: `terraform`, `kubectl`, `helm`, `aws-cli`

---

## Step-by-Step Setup

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/devsecops-pipeline.git
cd devsecops-pipeline
```

### 2. Provision infrastructure with Terraform
```bash
cd terraform

# Update backend bucket name in main.tf first, then:
terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public/private subnets across 2 AZs
- Amazon EKS cluster (v1.29) with managed node group
- Amazon ECR repository with scan-on-push enabled
- S3 backend with DynamoDB state locking

### 3. Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name devsecops-cluster
kubectl get nodes  # Verify cluster is ready
```

### 4. Set GitHub Actions secrets
In your GitHub repo → Settings → Secrets → Actions, add:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your IAM access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM secret key |

### 5. Apply the NetworkPolicy
```bash
kubectl create namespace devsecops
kubectl apply -f k8s/network-policy.yaml
```

### 6. Push code to trigger the pipeline
```bash
git add .
git commit -m "feat: initial devsecops pipeline"
git push origin main
```

The pipeline will automatically run all 6 stages. Watch it in the GitHub Actions tab.

---

## Pipeline Stages Explained

### Stage 1 — SAST (Bandit)
Bandit scans all Python source code for common security issues: hardcoded passwords, use of `eval()`, SQL injection patterns, insecure use of `subprocess`, etc. The pipeline **fails** if medium or higher severity issues are found.

### Stage 2 — Dependency Scan (Safety)
Safety checks `requirements.txt` against the PyPI advisory database for known CVEs in Flask, gunicorn, and any other dependencies.

### Stage 3 — Docker Build
Builds the container image using a hardened `python:3.12-slim` base. The image runs as a non-root user and includes a health check endpoint.

### Stage 4 — Container Scan (Trivy)
Trivy scans the built image for OS-level and library-level CVEs. The pipeline **fails and blocks the push** if any CRITICAL or HIGH severity vulnerabilities are found.

### Stage 5 — Push to ECR
Only reached after all security gates pass. Pushes the verified image to Amazon ECR with both the commit SHA tag and `latest`.

### Stage 6 — Deploy to EKS
Deploys to the `devsecops` namespace using Helm. Waits for rollout to complete before marking the pipeline as successful.

---

## Security Architecture Decisions

**Why non-root container?**
Running as root inside a container means a container escape gives an attacker root on the host. Setting `runAsUser: 1000` and `runAsNonRoot: true` eliminates this risk.

**Why read-only filesystem?**
Attackers who achieve code execution often write malicious files to disk. A read-only filesystem prevents persistence.

**Why NetworkPolicy?**
By default, all pods in a Kubernetes cluster can talk to each other. The NetworkPolicy enforces deny-all and only allows the minimum required traffic — this limits blast radius if a pod is compromised.

**Why block EC2 metadata endpoint?**
The EC2 metadata endpoint (169.254.169.254) can expose IAM credentials to any process inside the pod. The NetworkPolicy explicitly blocks this.

---

## Frameworks This Project Demonstrates

- **NIST 800-53**: SI-10 (Input Validation), SA-11 (Developer Testing), CM-7 (Least Functionality)
- **PCI-DSS**: Req 6.3 (Security vulnerabilities addressed), Req 6.4 (Public-facing app protection)
- **CIS Kubernetes Benchmark**: Pod security, RBAC, network policies

---

## Author

**George Awa, CISSP** | DevSecOps Engineer  
[LinkedIn](https://linkedin.com/in/georgeawa) · [GitHub](https://github.com/desbain)
